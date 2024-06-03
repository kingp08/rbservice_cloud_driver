import 'package:bedrive/drive/screens/settings-screen/sections/section-title.dart';
import 'package:bedrive/utils/local-storage.dart';
import 'package:bedrive/drive/dialogs/show-snackbar.dart';
import 'package:bedrive/utils/text.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DocumentCacheSection extends StatefulWidget {
  @override
  _DocumentCacheSectionState createState() => _DocumentCacheSectionState();
}

class _DocumentCacheSectionState extends State<DocumentCacheSection> {
  int? spaceUsed;

  @override
  void initState() {
    super.initState();
    _syncSpaceUsed();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(name: 'Document cache'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                await context.read<LocalStorage>().temporary.deleteContents();
                _syncSpaceUsed();
                showSnackBar(trans('Cache cleared'), context);
              },
              child: ListTile(
                title: text('Clear cache'),
                subtitle: text('Clear all cached documents (:size)', replacements: {'size': filesize(spaceUsed ?? 0)}),
              ),
            ),
          ],
        )
      ],
    );
  }

  _syncSpaceUsed() {
    setState(() {
      spaceUsed = context.read<LocalStorage>().temporary.spaceUsed();
    });
  }
}