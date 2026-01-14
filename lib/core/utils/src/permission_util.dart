import 'dart:io';

import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  static Future<void> showPermissionDialog(
    BuildContext context,
    String permissionType,
  ) async {
    final l10n = context.l10n;
    if (!context.mounted) return;
    await showDialog<bool>(
      context: context,
      builder: (modalContext) => Theme(
        data: ThemeData.light(),
        child: AlertDialog(
          title: Text(capitalize(permissionType)),
          content: Text(l10n.please_turn_on_permission(permissionType)),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(modalContext).pop();
                await openAppSettings();
              },
              child: Text(l10n.open_setting),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> checkPermission(
    BuildContext context,
    Permission permission, {
    void Function()? grantedCallback,
  }) async {
    void showDialog() =>
        PermissionUtil.showPermissionDialog(context, permission.toString());

    var permissionStatus = await permission.status;
    if (permissionStatus.isDenied) {
      permissionStatus = await permission.request();
      if (permissionStatus.isPermanentlyDenied) {
        return showDialog();
      } else {
        if (context.mounted) {
          await checkPermission(
            context,
            permission,
            grantedCallback: grantedCallback,
          );
        }
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      return showDialog();
    } else if (permissionStatus.isGranted ||
        permissionStatus.isLimited ||
        permissionStatus.isRestricted) {
      if (grantedCallback != null) {
        grantedCallback();
      }
    }
  }

  static Future<void> checkCameraPermission(
    BuildContext context, {
    void Function()? grantedCallback,
  }) async {
    void showDialog() =>
        PermissionUtil.showPermissionDialog(context, context.l10n.camera);
    Future<void> checkCamera() =>
        checkCameraPermission(context, grantedCallback: grantedCallback);

    var permissionStatus = await Permission.camera.status;
    if (permissionStatus.isDenied) {
      permissionStatus = await Permission.camera.request();
      if (permissionStatus.isPermanentlyDenied) {
        return showDialog();
      } else {
        await checkCamera();
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      return showDialog();
    } else if (permissionStatus.isGranted ||
        permissionStatus.isLimited ||
        permissionStatus.isRestricted) {
      if (grantedCallback != null) {
        grantedCallback();
      }
    }
  }

  static Future<void> checkPhotoPermission(
    BuildContext context, {
    void Function()? grantedCallback,
    void Function()? deniedCallback,
  }) async {
    void showDialog() =>
        PermissionUtil.showPermissionDialog(context, context.l10n.photo);

    var permission = Permission.photos;

    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          permission = Permission.storage;
        }
      } on Exception catch (e) {
        //Do nothing
        debugPrint('Error getting android info: $e');
      }
    }
    var permissionStatus = await permission.status;
    if (permissionStatus.isDenied) {
      permissionStatus = await permission.request();
      if (permissionStatus.isPermanentlyDenied) {
        if (deniedCallback != null) {
          deniedCallback();
        }
        return showDialog();
      } else {
        if (context.mounted) {
          await checkPhotoPermission(
            context,
            grantedCallback: grantedCallback,
            deniedCallback: deniedCallback,
          );
        }
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      debugPrint('permantent denied');
      return showDialog();
    } else if (permissionStatus.isGranted ||
        permissionStatus.isLimited ||
        permissionStatus.isRestricted) {
      debugPrint('granted go to callback $grantedCallback');

      if (grantedCallback != null) {
        debugPrint('trigger calback');
        grantedCallback();
      }
    }
  }
}
