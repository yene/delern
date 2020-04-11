import 'dart:io';

import 'package:delern_flutter/flutter/localization.dart';
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

typedef ImageSelected = void Function(File file);

enum _ImageMenuItemSource { gallery, photo }

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

  // TODO(ksheremet): Check whether camera is installed
  Future<File> _openImage(
      _ImageMenuItemSource imageSource, BuildContext context) async {
    File image;
    switch (imageSource) {
      case _ImageMenuItemSource.gallery:
        try {
          // Doesn't work for Android. It asks for permission every time
          // I push the button if I disallowed before
          // TODO(ksheremet): Handle Permission on Android, if they were
          // denied, offer to show app settings to enable it
          if (Platform.isIOS) {
            final permission =
                await _acquirePermission(context, PermissionGroup.photos);
            if (permission != PermissionStatus.granted) {
              UserMessages.showMessage(
                  Scaffold.of(context), context.l.galleryAccessUserMessage);
              break;
            }
          }
          image = await ImagePicker.pickImage(
            source: ImageSource.gallery,
            maxHeight: _kImageSideSizeLimit,
            maxWidth: _kImageSideSizeLimit,
          );
        } catch (e, stackTrace) {
          UserMessages.showAndReportError(
            () => Scaffold.of(context),
            e,
            stackTrace: stackTrace,
          );
        }
        break;
      case _ImageMenuItemSource.photo:
        try {
          // Android: permissions are denied when we use the feature fist time.
          // We don't need to open App Setting because it offers the standard
          // permission dialog if user didn't press don't show it anymore"
          // TODO(ksheremet): Distinguish between when permissions were denied
          // without showing "the standard permission dialog" and suggest to
          // go to settings
          final permission = await PermissionHandler()
              .checkPermissionStatus(PermissionGroup.camera);
          if (permission == PermissionStatus.granted ||
              permission == PermissionStatus.unknown ||
              Platform.isAndroid) {
            image = await ImagePicker.pickImage(
              source: ImageSource.camera,
              maxWidth: _kImageSideSizeLimit,
              maxHeight: _kImageSideSizeLimit,
            );
            break;
          } else {
            final permission =
                await _acquirePermission(context, PermissionGroup.camera);
            if (permission != PermissionStatus.granted) {
              UserMessages.showMessage(
                  Scaffold.of(context), context.l.cameraAccessUserMessage);
              break;
            }
          }
          image = await ImagePicker.pickImage(source: ImageSource.camera);
        } catch (e, stackTrace) {
          UserMessages.showAndReportError(
            () => Scaffold.of(context),
            e,
            stackTrace: stackTrace,
          );
        }
        break;
    }
    return image;
  }

  Future<PermissionStatus> _acquirePermission(
      BuildContext context, PermissionGroup permissionGroup) async {
    var permission =
        await PermissionHandler().checkPermissionStatus(permissionGroup);
    if (permission == PermissionStatus.unknown) {
      // Cannot request permission if they were denied before
      final reqPermissions =
          await PermissionHandler().requestPermissions([permissionGroup]);
      permission = reqPermissions[permissionGroup];
    } else {
      if (permission == PermissionStatus.denied) {
        // Show dialog where to offer to open App Settings
        final openAppSettings = await showSaveUpdatesDialog(
          context: context,
          changesQuestion: PermissionGroup.camera == permissionGroup
              ? context.l.openAppSettingsCameraAccessQuestion
              : context.l.openAppSettingsGalleryAccessQuestion,
          yesAnswer: context.l.open,
          noAnswer: MaterialLocalizations.of(context).cancelButtonLabel,
        );
        if (openAppSettings) {
          // TODO(ksheremet): Return to the same screen with adding cards after
          // opening the settings screen
          final hasOpened = await PermissionHandler().openAppSettings();
          if (!hasOpened) {
            UserMessages.showMessage(Scaffold.of(context),
                context.l.couldNotOpenAppSettingsUserMessage);
          }
        }
      }
    }

    return permission;
  }

  Map<_ImageMenuItemSource, Widget> _buildImageMenu(BuildContext context) =>
      <_ImageMenuItemSource, Widget>{
        _ImageMenuItemSource.gallery: ImageMenuItem(
          icon: Icons.add_photo_alternate,
          text: context.l.imageFromGalleryLabel,
        ),
        _ImageMenuItemSource.photo: ImageMenuItem(
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
