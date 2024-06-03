import 'package:bedrive/drive/screens/shareable-link/shareable-link-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bedrive/config/app-config.dart';
import 'package:bedrive/drive/dialogs/show-snackbar.dart';
import 'package:bedrive/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class CopyToClipboardButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final link = context.select((ShareableLinkState s) => s.link);
    return IconButton(
      icon: Icon(Icons.copy_outlined),
      tooltip: trans('Copy to clipboard'),
      onPressed: link == null ? null : () => _onPressed(context),
    );
  }

  _onPressed(BuildContext context) async {
    final hash = context.read<ShareableLinkState>().link!.hash;
    final backendUrl = context.read<AppConfig>().localConfig.baseBackendUrl;
    final linkUrl = '$backendUrl/drive/s/$hash';
    await Clipboard.setData(ClipboardData(text: linkUrl));
    await Clipboard.setData(ClipboardData(text: linkUrl));
    showSnackBar(trans('Copied link to clipboard.'), context);
  }
}

class ShareButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final link = context.select((ShareableLinkState s) => s.link);
    return IconButton(
      icon: Icon(Icons.share_outlined),
      tooltip: trans('Share'),
      onPressed: link == null ? null : () => _onPressed(context),
    );
  }

  _onPressed(BuildContext context) {
    final hash = context.read<ShareableLinkState>().link!.hash;
    final backendUrl = context.read<AppConfig>().localConfig.baseBackendUrl;
    final linkUrl = '$backendUrl/drive/s/$hash';
    Share.share(linkUrl,
        subject: context.read<ShareableLinkState>().fileEntry!.name);
  }
}

class DeleteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final link = context.select((ShareableLinkState s) => s.link);
    return IconButton(
      icon: Icon(Icons.delete_outline_outlined),
      tooltip: trans('Delete'),
      onPressed: link == null ? null : () => _onPressed(context),
    );
  }

  _onPressed(BuildContext context) async {
    try {
      await context.read<ShareableLinkState>().deleteLink();
      showSnackBar(trans('Deleted link.'), context);
    } catch (e) {
      showSnackBar(trans('There was an issue with deleting link.'), context);
    }
  }
}
