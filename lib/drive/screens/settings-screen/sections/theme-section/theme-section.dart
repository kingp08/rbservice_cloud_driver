import 'package:bedrive/drive/screens/settings-screen/sections/section-title.dart';
import 'package:bedrive/drive/screens/settings-screen/sections/theme-section/select-theme-dialog.dart';
import 'package:bedrive/drive/state/preference-state.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedMode = context.select((PreferenceState s) => s.themeMode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(name: 'Theme'),
        ListTile(
          onTap: () async {
            final newMode = await showChooseThemeDialog(context);
            if (newMode != null) {
              context.read<PreferenceState>().setThemeMode(newMode);
            }
          },
          title: text('Choose theme'),
          subtitle: _subtitle(selectedMode),
        ),
      ],
    );

  }

  _subtitle(ThemeMode selectedMode) {
    switch(selectedMode) {
      case ThemeMode.dark:
        return text('Dark');
      case ThemeMode.light:
        return text('Light');
      default:
        return text('System default');
    }
  }
}
