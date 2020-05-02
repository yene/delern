import 'package:flutter/services.dart';

void hideTextInput() {
  // Hide TextInput
  // https://stackoverflow.com/questions/44991968
  SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
}
