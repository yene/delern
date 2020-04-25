import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:delern_flutter/flutter/localization.dart';
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

typedef ImageSelected = void Function(File file);

const double _kImageSideSizeLimit = 600;

class PickImageMenuWidget extends StatelessWidget {
  final ImageSelected onImageSelected;

  const PickImageMenuWidget({@required this.onImageSelected, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _buildImageMenu(context)
            .entries
            .map((entry) => GestureDetector(
                  onTap: () async {
                    final file = await _openImage(entry.key, context);
                    if (file != null) {
                      onImageSelected(file);
                    }
                  },
                  child: entry.value,
                ))
            .toList(),
      );

  Future<File> _openImage(ImageSource source, BuildContext context) async {
    try {
      final file = await ImagePicker.pickImage(
        source: source,
        maxWidth: _kImageSideSizeLimit,
        maxHeight: _kImageSideSizeLimit,
      );
      if (file != null) {
        return file;
      }
    } on PlatformException {
      await AppSettings.openAppSettings();
    } catch (e, stackTrace) {
      UserMessages.showAndReportError(
        () => Scaffold.of(context),
        e,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  Map<ImageSource, Widget> _buildImageMenu(BuildContext context) =>
      <ImageSource, Widget>{
        ImageSource.gallery: ImageMenuItem(
          icon: Icons.add_photo_alternate,
          text: context.l.imageFromGalleryLabel,
        ),
        ImageSource.camera: ImageMenuItem(
          icon: Icons.add_a_photo,
          text: context.l.imageFromPhotoLabel,
        ),
      };
}

@immutable
class ImageMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const ImageMenuItem({@required this.icon, @required this.text})
      : assert(icon != null),
        assert(text != null);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: app_styles.kLightPrimaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                icon,
                size: app_styles.kImageMenuButtonSize,
                semanticLabel: text,
              ),
            ),
          ),
          Text(
            text,
            style: app_styles.primaryText.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
}
