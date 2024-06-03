import 'package:bedrive/drive/screens/file-preview/file-preview-state.dart';
import 'package:bedrive/drive/screens/file-preview/generic-file-preview.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:provider/provider.dart';

class PdfFilePreview extends StatefulWidget {
  const PdfFilePreview(this.fileEntry, {
    Key? key,
  }) : super(key: key);

  final FileEntry fileEntry;

  @override
  _PdfFilePreviewState createState() => _PdfFilePreviewState();
}

class _PdfFilePreviewState extends State<PdfFilePreview> {
  PdfController? controller;
  bool error = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setContents();
    });
    super.initState();
  }

  _setContents() async {
    final previewState = context.read<FilePreviewState>();
    final localFile = await previewState.getLocallyStoredFile(context, download: true);
    if (localFile != null) {
      controller = PdfController(
        document: PdfDocument.openFile(localFile.path),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return GenericFilePreview(widget.fileEntry);
    }
    return PdfView(
      controller: controller!,
    );
  }
}
