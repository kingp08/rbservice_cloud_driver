import 'package:bedrive/drive/screens/file-preview/file-preview-state.dart';
import 'package:bedrive/drive/screens/file-preview/generic-file-preview.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:provider/provider.dart';

class TextFilePreview extends StatefulWidget {
  const TextFilePreview(this.fileEntry, {
    Key? key,
  }) : super(key: key);

  final FileEntry fileEntry;

  @override
  _TextFilePreviewState createState() => _TextFilePreviewState();
}

class _TextFilePreviewState extends State<TextFilePreview> {
  bool loading = true;
  String textContent = '';
  bool error = false;

  @override
  void initState() {
    _setContents();
    super.initState();
  }

  _setContents() async {
    final previewState = context.read<FilePreviewState>();
    final api = context.read<DriveState>().api;
    final localFile = await previewState.getLocallyStoredFile(context);
    if (localFile != null) {
      textContent = await localFile.readAsString();
    } else {
      try {
        textContent = await api.getFileContents(widget.fileEntry);
      } on BackendError {
        error = true;
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error) {
      return GenericFilePreview(widget.fileEntry);
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Text(textContent),
      ),
    );
  }
}
