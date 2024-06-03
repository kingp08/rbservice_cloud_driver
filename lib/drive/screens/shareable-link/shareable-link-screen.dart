import 'package:bedrive/drive/screens/shareable-link/footer/shareable-link-footer.dart';
import 'package:bedrive/drive/screens/shareable-link/shareable-link-form-key.dart';
import 'package:bedrive/drive/screens/shareable-link/shareable-link-state.dart';
import 'package:bedrive/drive/screens/shareable-link/shareable-link.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/utils/text.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShareableLinkArgs {
  ShareableLinkArgs(this.fileEntry);
  final FileEntry? fileEntry;
}

class ShareableLinkScreen extends StatelessWidget {
  static const ROUTE = 'shareableLink';
  @override
  Widget build(BuildContext context) {
    final fileEntry = context.select(((ShareableLinkState s) => s.fileEntry!));
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text(fileEntry.name, translate: false),
            SizedBox(height: 2),
            text('Shareable link', size: 14),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Body(),
      ),
      bottomNavigationBar: ShareableLinkFooter(),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final initialLoadCompleted =
        context.select((ShareableLinkState s) => s.initialLoadCompleted);
    return initialLoadCompleted == false
        ? Container()
        : Container(
            padding: EdgeInsets.all(15),
            child: Form(
              key: shareableLinkFormKey,
              child: Column(
                children: [
                  ExpirationFormField(),
                  SizedBox(height: 25),
                  Divider(thickness: 1),
                  PasswordFormField(),
                  SizedBox(height: 25),
                  Divider(thickness: 1),
                  AllowEditingField(),
                  SizedBox(height: 25),
                  Divider(thickness: 1),
                  AllowDownloadFormField(),
                ],
              ),
            ),
          );
  }
}

class ExpirationFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final expirationEnabled = context.select((ShareableLinkState s) {
      return s.expirationEnabled! || s.formPayload['expiresAt'] != null;
    });
    final link = context.select((ShareableLinkState s) => s.link);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.all(0),
          title: text('Link expiration',
              style: Theme.of(context).textTheme.subtitle1),
          value: expirationEnabled,
          onChanged: (value) {
            context.read<ShareableLinkState>().toggleExpirationEnabled(value);
          },
        ),
        expirationEnabled ? _formField(link, context) : Container(),
      ],
    );
  }

  _formField(ShareableLink? link, BuildContext context) {
    final form = context.read<ShareableLinkState>().formPayload;
    return DateTimePicker(
        onSaved: (v) =>
            context.read<ShareableLinkState>().formPayload['expiresAt'] = v,
        type: DateTimePickerType.dateTime,
        initialValue:
            form['expiresAt'] != null ? form['expiresAt'].toString() : null,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 300)),
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: trans('Link is valid until'),
        ));
  }
}

class PasswordFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final passwordEnabled =
        context.select(((ShareableLinkState s) => s.passwordEnabled!));
    final link = context.select((ShareableLinkState s) => s.link);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.all(0),
          title: text('Require password',
              style: Theme.of(context).textTheme.subtitle1),
          value: passwordEnabled || link?.password != null,
          onChanged: (value) {
            context.read<ShareableLinkState>().togglePasswordEnabled(value);
          },
        ),
        passwordEnabled ? _formField(link, context) : Container(),
      ],
    );
  }

  TextFormField _formField(ShareableLink? link, BuildContext context) {
    // TODO: use focus node to focus this and expires_at when checkbox is toggled on
    return TextFormField(
        onChanged: (v) =>
            context.read<ShareableLinkState>().formPayload['password'] = v,
        obscureText: true,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: trans('Enter new password...'),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ));
  }
}

class AllowEditingField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool allowEdit = context
        .select((ShareableLinkState s) => s.formPayload['allowEdit'] ?? false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.all(0),
          title: text('Allow editing',
              style: Theme.of(context).textTheme.subtitle1),
          value: allowEdit,
          onChanged: (value) {
            context.read<ShareableLinkState>().setFormValue('allowEdit', value);
          },
        ),
        text('Should people with link be able to modify this item.')
      ],
    );
  }
}

class AllowDownloadFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final allowDownload = context.select(
        (ShareableLinkState s) => s.formPayload['allowDownload'] ?? false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.all(0),
          title: text('Allow download',
              style: Theme.of(context).textTheme.subtitle1),
          value: allowDownload,
          onChanged: (value) {
            context
                .read<ShareableLinkState>()
                .setFormValue('allowDownload', value);
          },
        ),
        text('Should people with link be able to download this item.')
      ],
    );
  }
}
