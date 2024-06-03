import 'package:bedrive/drive/screens/settings-screen/sections/about-section.dart';
import 'package:bedrive/drive/screens/settings-screen/sections/account-section.dart';
import 'package:bedrive/drive/screens/settings-screen/sections/document-cache-section.dart';
import 'package:bedrive/drive/screens/settings-screen/sections/notifications-section.dart';
import 'package:bedrive/drive/screens/settings-screen/sections/theme-section/theme-section.dart';
import 'package:bedrive/drive/state/space-usage/space-usage-state.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const ROUTE = 'settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SpaceUsageState>().sync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15, bottom: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccountSection(),
              const Divider(),
              NotificationSection(),
              const Divider(),
              DocumentCacheSection(),
              const Divider(),
              ThemeSection(),
              const Divider(),
              AboutSection(),
            ],
          ),
        )
      ),
    );
  }
}

