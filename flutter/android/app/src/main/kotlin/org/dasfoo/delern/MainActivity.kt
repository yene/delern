package org.dasfoo.delern

import android.os.Bundle
import android.provider.Settings
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.database.FirebaseDatabase
import com.google.firebase.database.Logger
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val testLabSetting = Settings.System.getString(contentResolver, "firebase.test.lab")
        if (!"true".equals(testLabSetting)) {
            // Re-enable Analytics when not in Firebase Test Lab. See AndroidManifest.xml for details.
            // Documentation on detecting Firebase Test Lab:
            // https://firebase.google.com/docs/test-lab/android/android-studio
            FirebaseAnalytics.getInstance(this).setAnalyticsCollectionEnabled(true)
        }

        if (BuildConfig.DEBUG) {
            // TODO(dotdoom): this should be placed in main.dart once it's available in Flutter.
            //FirebaseDatabase.getInstance().setLogLevel(Logger.Level.DEBUG)
        }
    }
}
