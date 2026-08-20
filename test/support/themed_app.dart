import 'package:flutter/material.dart';
import 'package:tone_vault/app/theme/app_theme.dart';

/// A [MaterialApp] carrying the app's own theme, wrapping [home] in a Scaffold.
///
/// Worth using over a bare MaterialApp wherever a sheet, a dialog or a row of
/// buttons is pumped: the theme sizes buttons and fields, and a layout that is
/// fine under Flutter's defaults can still throw under this one. The value
/// editor sheet did exactly that - it opened and threw on the app theme's
/// full-width FilledButton, so on a phone tapping a control looked like nothing
/// at all.
Widget themedApp(Widget home) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: home),
  );
}
