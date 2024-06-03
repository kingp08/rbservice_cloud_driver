import 'package:bedrive/drive/dialogs/show-snackbar.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/screens/shareable-link/footer/shareable-link-footer-action-buttons.dart';
import 'package:bedrive/drive/screens/shareable-link/shareable-link-form-key.dart';
import 'package:bedrive/drive/screens/shareable-link/shareable-link-state.dart';
import 'package:bedrive/drive/screens/shareable-link/shareable-link.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/utils/text.dart';
import 'package:provider/provider.dart';

class ShareableLinkFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Container(
        height: 52,
        child: Stack(
          children: [
            ProgressIndicator(),
            Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CopyToClipboardButton(),
                        ShareButton(),
                        DeleteButton(),
                      ],
                    ),
                    SubmitButton(),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((ShareableLinkState s) => s.loading);
    return isLoading ? LinearProgressIndicator() : Container(height: 4);
  }
}

class SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loading = context.select((ShareableLinkState s) => s.loading != false);
    final link = context.select((ShareableLinkState s) => s.link);
    return Container(
      child: ElevatedButton(
        child: text(_getText(loading, link)),
        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
        onPressed: loading ? null : () => _submit(context),
      ),
    );
  }

  _submit(BuildContext context) async {
    final state = context.read<ShareableLinkState>();
    bool creating = state.link == null;
    try {
      if (shareableLinkFormKey.currentState!.validate()) {
        shareableLinkFormKey.currentState!.save();
        await state.crupdateLink();
        showSnackBar(trans('Link ${creating ? 'created' : 'updated'}'), context);
      }
    } on BackendError catch(e) {
      showSnackBar(trans(e.message), context);
    }
  }

  String _getText(bool loading, ShareableLink? link) {
    if (loading) {
      return 'Loading...';
    } else if (link != null) {
      return 'Update';
    } else {
      return 'Create';
    }
  }
}