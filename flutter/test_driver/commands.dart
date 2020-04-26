import 'dart:convert';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:meta/meta.dart';

const kGetWindow = 'GetWindow';

class Window {
  final double width;
  final double height;

  const Window({
    @required this.width,
    @required this.height,
  });

  Window.fromJson(Map<String, dynamic> json)
      : width = json['width'],
        height = json['height'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'width': width,
        'height': height,
      };
}

extension CustomCommands on FlutterDriver {
  Future<Window> getWindow() async =>
      Window.fromJson(json.decode(await requestData(kGetWindow)));
}
