import 'package:bedrive/auth/auth-state.dart';
import 'package:bedrive/drive/dialogs/confirm-file-deletion-dialog.dart';
import 'package:bedrive/drive/screens/settings-screen/sections/section-title.dart';
import 'package:bedrive/drive/state/root-navigator-key.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.select(((AuthState s) => s.currentUser!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(name: 'Account'),
        ListTile(
          title: text(currentUser.email, translate: false),
          subtitle: text('Sign out'),
          trailing: Icon(Icons.exit_to_app_outlined, color: Theme.of(context).primaryColor),
          onTap: () async {
            final confirmed = await showConfirmationDialog(
              rootNavigatorKey.currentContext!,
              title: 'Sign out',
              subtitle: 'Are you sure you want to sign out of this account?',
              confirmText: 'Sign out',
            );
            if (confirmed != null) {
              context.read<AuthState>().logout(context);
            }
          },
        ),
      ],
    );
  }
}