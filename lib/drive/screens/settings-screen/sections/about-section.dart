import 'package:bedrive/auth/auth-state.dart';
import 'package:bedrive/config/app-config.dart';
import 'package:bedrive/config/dynamic-menu.dart';
import 'package:bedrive/drive/dialogs/show-snackbar.dart';
import 'package:bedrive/drive/http/app-http-client.dart';
import 'package:bedrive/drive/screens/settings-screen/sections/section-title.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bedrive/drive/dialogs/confirm-file-deletion-dialog.dart';

class AboutSection extends StatefulWidget {
  @override
  _AboutSectionState createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  String? version;

  @override
  void initState() {
    super.initState();
    version = context.read<AppConfig>().version;
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.select((AppConfig c) => c.menus[MenuPosition.aboutSection]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(name: 'About'),
        ListTile(
          title: text('Version'),
          subtitle: text(version, translate: false),
        ),
        Divider(),
        ..._getMenuItems(context, menu),
      ],
    );
  }

  List<ListTile> _getMenuItems(BuildContext context, DynamicMenu? menu) {
    final http = context.select((AppHttpClient s) => s);
    List<ListTile> items = [
      ListTile(
        title: text('View Licenses'),
        onTap: () => showLicensePage(context: context),
      ),
      ListTile(
        title: text('Delete Account'),
        onTap: () async {
          final http = context.read<AppHttpClient>();
          final auth = context.read<AuthState>();
          final confirmed = await showConfirmationDialog(
              context,
              title: 'Delete account?',
              subtitle: 'Your account will be deleted immediately and permanently. Once deleted, accounts can not be restored.',
              confirmText: 'Delete'
          );
          if (confirmed != null) {
           try {
             await http.delete('/users/${auth.currentUser!.id}', {'deleteCurrentUser': true});
             auth.logout(context);
           } catch(e) {
             showSnackBar(trans('Could not delete account.'), context);
           }
          }
        },
      )
    ];
    if (menu != null) {
      final menuItems = menu.items!.map((i) {
        return ListTile(
          title: text(i.label),
          onTap: () async {
            final urlString = http.prefixUrl(i.action!);
            final url = Uri.parse(urlString);
            if (await canLaunchUrl(url)) {
              launchUrl(url);
            }
          },
        );
      });
      items = [...menuItems, ...items];
    }

    return items;
  }
}