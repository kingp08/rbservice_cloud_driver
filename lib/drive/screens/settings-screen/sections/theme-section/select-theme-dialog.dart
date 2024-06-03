import 'package:bedrive/drive/state/preference-state.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/utils/text.dart';
import 'package:provider/provider.dart';

Future<ThemeMode?> showChooseThemeDialog(BuildContext context) {
  return showDialog<ThemeMode>(
    context: context,
    builder: (BuildContext context) {
      final selected = context.select((PreferenceState s) => s.themeMode);
      return AlertDialog(
        title: text('Choose theme'),
        contentPadding: EdgeInsets.only(top: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RadioListTile<ThemeMode>(
              title: text('Dark'),
              value: ThemeMode.dark,
              groupValue: selected,
              onChanged: (ThemeMode? value) => Navigator.of(context).pop(value),
            ),
            RadioListTile<ThemeMode>(
              title: text('Light'),
              value: ThemeMode.light,
              groupValue: selected,
              onChanged: (ThemeMode? value) => Navigator.of(context).pop(value),
            ),
            RadioListTile<ThemeMode>(
              title: text('System default'),
              value: ThemeMode.system,
              groupValue: selected,
              onChanged: (ThemeMode? value) => Navigator.of(context).pop(value),
            ),
          ]
        ),
        actions: [
          ElevatedButton(
            child: text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
        ],
      );
    },
  );
}