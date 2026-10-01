import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AppMessage {
  AppMessage._();

  static void success(
    BuildContext context, {
    String title = 'نجاح',
    required String message,
  }) {
    _show(context, type: DialogType.success, title: title, message: message);
  }

  static void error(
    BuildContext context, {
    String title = 'خطأ',
    required String message,
  }) {
    _show(context, type: DialogType.error, title: title, message: message);
  }

  static void warning(
    BuildContext context, {
    String title = 'تحذير',
    required String message,
  }) {
    _show(context, type: DialogType.warning, title: title, message: message);
  }

  static void info(
    BuildContext context, {
    String title = 'معلومات',
    required String message,
  }) {
    _show(context, type: DialogType.info, title: title, message: message);
  }

  static void _show(
    BuildContext context, {
    required DialogType type,
    required String title,
    required String message,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: 'حسنًا',
      btnOkOnPress: () {},
    ).show();
  }
}
