import 'dart:io';

import 'package:delern_flutter/flutter/localization.dart';
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedantic/pedantic.dart';
import 'package:permission_handler/permission_handler.dart';

typedef ImageSelected = void Function(File file);

enum _ImageMenuItemSource { gallery, photo }

const double _kImageSideSizeLimit = 600;

class PickImageMenuWidget extends StatelessWidget {
  final ImageSelected onImageSelected;

  const PickImageMenuWidget({@required this.onImageSelected, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => PopupMenuButton<_ImageMenuItemSource>(
        icon: Icon(
          Icons.camera_alt,
          size: app_styles.kImageMenuButtonSize,
          semanticLabel: context.l.accessibilityAddImageLabel,
        ),
        onSelected: (source) async {
          final file = await _openImage(source, context);
          if (file != null) {
            onImageSelected(file);
          }
        },
        itemBuilder: (context) => _buildImageMenu(context)
            .entries
            .map((entry) => PopupMenuItem<_ImageMenuItemSource>(
                  value: entry.key,
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
          UserMessages.showMessage(Scaffold.of(context),
              UserMessages.formUserFriendlyErrorMessage(context.l, e));
          unawaited(error_reporting.report(
              'Getting image from Gallery failed', e, stackTrace));
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
          UserMessages.showMessage(Scaffold.of(context),
              UserMessages.formUserFriendlyErrorMessage(context.l, e));
          unawaited(
              error_reporting.report('Taking picture failed', e, stackTrace));
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

  Widget _buildImageMenuItem(IconData icon, String text) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            semanticLabel: text,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(text),
          ),
        ],
      );

  Map<_ImageMenuItemSource, Widget> _buildImageMenu(BuildContext context) =>
      <_ImageMenuItemSource, Widget>{
        _ImageMenuItemSource.gallery: _buildImageMenuItem(
            Icons.add_photo_alternate, context.l.imageFromGalleryLabel),
        _ImageMenuItemSource.photo: _buildImageMenuItem(
            Icons.add_a_photo, context.l.imageFromPhotoLabel),
      };
}
