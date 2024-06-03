import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<FileEntry?> showCrupdateEntryDialog(BuildContext context, {String fileType = 'file', FileEntry? fileEntry}) {
  return showDialog<FileEntry>(
    context: context,
    builder: (BuildContext context) {
      return CrupdateFileDialog(fileType: fileEntry?.type ?? fileType, fileEntry: fileEntry);
    }
  );
}

class CrupdateFileDialog extends StatefulWidget {
  final FileEntry? fileEntry;
  final String fileType;
  final renaming = false;

  CrupdateFileDialog({this.fileEntry, this.fileType = 'file'});

  @override
  CrupdateFileDialogState createState() {
    return CrupdateFileDialogState(fileEntry: fileEntry);
  }
}

class CrupdateFileDialogState extends State<CrupdateFileDialog> {
  final FileEntry? fileEntry;
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  Map<String, String?> backendErrors = {};
  final Map<String, String?> formPayload = {};

  CrupdateFileDialogState({FileEntry? fileEntry}) : this.fileEntry = fileEntry;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: text('${widget.fileEntry != null ? 'Rename' : 'Create'} ${widget.fileType == 'folder' ? 'folder' : 'file'}'),
      actionsPadding: EdgeInsets.fromLTRB(0, 8, 15, 4),
      content: Form(
        key: _formKey,
        child: TextFormField(
          onSaved: (v) => formPayload['name'] = v,
          initialValue: fileEntry?.name,
          autofocus: true,
          onFieldSubmitted: _submitForm,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: trans('New Name'),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            errorMaxLines: 2,
          ),
          validator: (val) {
            return backendErrors['name'];
          },
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
      actions: [
        TextButton(
          child: text('Cancel'),
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).textTheme.bodyText2!.color),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: text(widget.fileEntry != null ? 'Rename' : 'Create'),
          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
          onPressed: loading ? null : _submitForm,
        ),
      ],
    );
  }

  _submitForm([String? _]) async {
    backendErrors = {};
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() => loading = true);
        final newFileEntry = await _createOrRenameEntry(formPayload['name']);
        Navigator.of(context).pop(newFileEntry);
      } on BackendError catch(e) {
        if (e.errors.isNotEmpty) {
          backendErrors = e.errors;
        } else if (e.message != null) {
          backendErrors = {'name': e.message};
        }
        _formKey.currentState!.validate();
      } finally {
        setState(() => loading = false);
      }
    }
  }

  Future<dynamic> _createOrRenameEntry(String? newName) {
    if (fileEntry != null) {
      return context.read<DriveState>().renameFile(fileEntry!, name: newName);
    } else {
      return context.read<DriveState>().createFolder(newName);
    }
  }
}
