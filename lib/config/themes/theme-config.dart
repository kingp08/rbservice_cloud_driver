import 'package:flutter/material.dart';
import 'package:bedrive/config/themes/backend-theme-config.dart';

ThemeData buildTheme(BuildContext context, BackendThemeConfig themeConfig) {
  return ThemeData(
    brightness: themeConfig.isDark! ? Brightness.dark : Brightness.light,
    primaryColor: themeConfig.colors!['primary'],
    buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
        buttonColor: themeConfig.colors!['primary']),
    primaryColorLight: themeConfig.colors!['primary-light'],
    primaryColorDark: themeConfig.colors!['primary-dark'],
    selectedRowColor: themeConfig.colors!['emphasis'],
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: themeConfig.colors!['primary'],
      selectionColor: themeConfig.colors!['primary-light'],
      selectionHandleColor: themeConfig.colors!['primary'],
    ),
    listTileTheme:
        ListTileThemeData(selectedColor: themeConfig.colors!['primary']),
    dividerColor: themeConfig.colors!['divider'],
    backgroundColor: themeConfig.colors!['background'],
    cardColor: themeConfig.colors!['background-alt'],
    scaffoldBackgroundColor: themeConfig.colors!['background-alt'],
    dialogBackgroundColor: themeConfig.colors!['background'],
    hintColor: themeConfig.colors!['--be-hint-text'],
    canvasColor: themeConfig.colors!['background'],
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: themeConfig.colors!['primary'])),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            foregroundColor: themeConfig.colors!['primary'])),
    appBarTheme: AppBarTheme(
      backgroundColor: themeConfig.isDark!
          ? themeConfig.colors!['background-alt']
          : themeConfig.colors!['primary'],
      iconTheme: IconThemeData(
        color: themeConfig.isDark!
            ? themeConfig.colors!['text-main']
            : themeConfig.colors!['on-primary'],
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
        color: themeConfig.colors!['primary'],
        linearTrackColor: themeConfig.colors!['primary-light'],
        circularTrackColor: themeConfig.colors!['primary-light']),
    iconTheme: IconThemeData(
      color: themeConfig.colors!['text-muted'],
    ),
    textTheme: Theme.of(context).textTheme.apply(
          bodyColor: themeConfig.colors!['text-main'],
          displayColor: themeConfig.colors!['text-muted'],
        ),
    primaryTextTheme: Theme.of(context).textTheme.apply(
          bodyColor: themeConfig.colors!['on-primary'],
          displayColor: themeConfig.colors!['on-primary'],
        ),
    toggleableActiveColor: themeConfig.colors!['primary'],
  ).copyWith(
      pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
      }));
}
