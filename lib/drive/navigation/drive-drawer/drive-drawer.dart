import 'package:bedrive/auth/auth-state.dart';
import 'package:bedrive/drive/http/app-http-client.dart';
import 'package:bedrive/drive/navigation/drive-drawer/storage-usage.dart';
import 'package:bedrive/drive/screens/offline-entries-screen.dart';
import 'package:bedrive/drive/screens/settings-screen/settings-screen.dart';
import 'package:bedrive/drive/screens/trash-screen.dart';
import 'package:bedrive/transfers/transfers-screen/transfers-screen.dart';
import 'package:bedrive/utils/text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriveDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _CurrentUser(),
          ListTile(
            leading: Icon(Icons.compare_arrows_outlined),
            title: text('Transfers', weight: FontWeight.normal),
            onTap: () {
              Navigator.of(context).pop();
              TransfersScreen.open();
            },
          ),
          ListTile(
            leading: Icon(Icons.offline_pin_outlined),
            title: text('Files available offline', weight: FontWeight.normal),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(OfflineEntriesScreen.ROUTE);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline_outlined),
            title: text('Recycle bin', weight: FontWeight.normal),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(TrashScreen.ROUTE);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined),
            title: text('Settings', weight: FontWeight.normal),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(SettingsScreen.ROUTE);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app_outlined),
            title: text('Sign out', weight: FontWeight.normal),
            onTap: () {
              context.read<AuthState>().logout(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
                width: 24,
                alignment: Alignment.topLeft,
                child: const Icon(Icons.storage_outlined)),
            title: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: text('Storage', weight: FontWeight.normal),
            ),
            subtitle: StorageUsage(),
          ),
        ],
      ),
    );
  }
}

class _CurrentUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.select(((AuthState s) => s.currentUser!));
    final http = context.watch<AppHttpClient>();
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).primaryColor
              : Theme.of(context).backgroundColor),
      accountName: text(currentUser.displayName,
          translate: false, color: Theme.of(context).iconTheme.color),
      accountEmail: text(currentUser.email,
          translate: false, color: Theme.of(context).iconTheme.color),
      currentAccountPicture: CircleAvatar(
        radius: 15,
        backgroundImage: currentUser.avatar != null
            ? CachedNetworkImageProvider(http.prefixUrl(currentUser.avatar!))
            : null,
        child: currentUser.avatar == null
            ? Text(currentUser.displayName!.substring(1, 3))
            : null,
      ),
    );
  }
}
