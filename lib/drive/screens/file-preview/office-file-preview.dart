import 'package:bedrive/drive/http/file-entries-api.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OfficeFilePreview extends StatelessWidget {
  const OfficeFilePreview(
    this.fileEntry, {
    Key? key,
  }) : super(key: key);

  final FileEntry fileEntry;

  @override
  Widget build(BuildContext context) {
    final api = context.select((FileEntriesApi s) => s);
    final fileUrl = api.previewUrl(fileEntry)!;

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
          'https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeComponent(fileUrl)}'));

    return Container(
      transform: Matrix4.translationValues(-1, -1.1, 0),
      child: Center(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
