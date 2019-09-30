import * as child_process from 'child_process';
import * as firebase_admin from 'firebase-admin';
import * as firebase_tools from 'firebase-tools';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

if (process.argv.length !== 3) {
  console.error('This command takes exactly 1 argument: project id');
  process.exit(1);
}

const projectId = process.argv[2];
const displayName = 'Delern DEBUG';
const packageName = 'org.dasfoo.delern.debug';

console.log(`Terraforming Firebase project: <${projectId}>.`);

const stealFirebaseCredentials = () => {
  const api = require('firebase-tools/lib/api.js'),
    configstore = require('firebase-tools/lib/configstore.js'),
    tokens = configstore.get('tokens');
  return {
    clientId: api.clientId,
    clientSecret: api.clientSecret,
    refreshToken: tokens.refresh_token,
    type: tokens.token_type,
  };
};

const findOrCreateAndroidApp = async (
  app: firebase_admin.app.App
): Promise<string> => {
  const androidApps = await Promise.all(
    (await app.projectManagement().listAndroidApps()).map(app =>
      app.getMetadata()
    )
  );
  const androidApp = androidApps.find(app => app.packageName === packageName);
  if (androidApp) {
    return androidApp.appId;
  } else {
    return (await app
      .projectManagement()
      .createAndroidApp(packageName, displayName)).appId;
  }
};

const findOrCreateIOSApp = async (
  app: firebase_admin.app.App
): Promise<string> => {
  const iosApps = await Promise.all(
    (await app.projectManagement().listIosApps()).map(app => app.getMetadata())
  );
  const iosApp = iosApps.find(app => app.bundleId === packageName);
  if (iosApp) {
    return iosApp.appId;
  } else {
    return (await app
      .projectManagement()
      .createIosApp(packageName, displayName)).appId;
  }
};

(async (): Promise<void> => {
  await firebase_tools.login();

  const projects: Array<{
    name: string;
    id: string;
    permission: string;
    instance: string;
  }> = await firebase_tools.list();

  if (projects.findIndex(p => p.id === projectId) < 0) {
    await firebase_tools.projects.create(projectId, {
      displayName,
    });
  }

  const app = firebase_admin.initializeApp({
    credential: firebase_admin.credential.refreshToken(
      stealFirebaseCredentials()
    ),
    projectId,
  });

  const androidApp = app
      .projectManagement()
      .androidApp(await findOrCreateAndroidApp(app)),
    iosApp = app.projectManagement().iosApp(await findOrCreateIOSApp(app));

  const hashes =
    child_process
      .spawnSync('keytool', [
        '-list',
        '-v',
        '-keystore',
        path.join(os.homedir(), '.android', 'debug.keystore'),
        '-alias',
        'androiddebugkey',
        '-storepass',
        'android',
        '-keypass',
        'android',
      ])
      .stdout.toString()
      .match(/(..:){19,31}..$/gm) || [];
  for (const sha of hashes) {
    try {
      await androidApp.addShaCertificate(
        app.projectManagement().shaCertificate(sha.replace(/:/g, ''))
      );
    } catch (error) {
      if (error.code !== 'project-management/already-exists') {
        throw error;
      }
    }
  }

  fs.writeFileSync(
    '../flutter/android/app/google-services.json',
    await androidApp.getConfig()
  );
  fs.writeFileSync(
    '../flutter/ios/Runner/GoogleService-Info/' + packageName,
    await iosApp.getConfig()
  );

  await firebase_tools.deploy({
    project: projectId,
    message: 'Deployed by terraform',
    force: true,
  });

  const sha1 = hashes.find(value => value.length === 59);
  console.log(`Terraforming (mostly) complete!

Do not forget to make the following steps:

- [⚠️ required] go to
  https://console.firebase.google.com/project/${projectId}/authentication/providers
  and ensure the following providers are enabled:
  * [⚠️ required] Anonymous
  * [optional] Google

- [optional, required for Google authentication only] go to
  https://console.developers.google.com/apis/credentials/oauthclient?project=${projectId}
  and create an OAuth2 Client ID:
  * Application type: Android
  * Signing-certificate fingerprint: ${sha1}
  * Package name: ${packageName}

- [optional] go to
  https://console.firebase.google.com/project/${projectId}/analytics/app/android:${packageName}/overview
  and Enable Google Analytics

- [⚠️ required] if you have done anything per the steps above, re-run this script
  to download updated artifacats for Android and iOS apps

Have a nice day!`);
})()
  .then(() => {
    process.exit(0);
  })
  .catch(e => {
    console.error('Terraforming has failed!', e);
    process.exit(1);
  });
