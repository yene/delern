import 'package:delern_flutter/main.dart' as app;
import 'package:delern_flutter/remote/auth.dart';
import 'package:flutter_driver/driver_extension.dart';

Future<void> main() async {
  // This line enables the extension
  enableFlutterDriverExtension();
  // Sign out before running tests to clear cached data
  await Auth.instance.signOut();
  // Call the `main()` of your app or call `runApp` with whatever widget
  // you are interested in testing.
  await app.main();
}
