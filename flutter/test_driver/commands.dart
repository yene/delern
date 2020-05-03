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

  Window.fromJson(dynamic json)
      : width = json['width'] as double, // ignore: avoid_as
        height = json['height'] as double; // ignore: avoid_as

  Map<String, dynamic> toJson() => <String, dynamic>{
        'width': width,
        'height': height,
      };
}

extension CustomCommands on FlutterDriver {
  Future<Window> getWindow() async =>
      Window.fromJson(json.decode(await requestData(kGetWindow)));
}
