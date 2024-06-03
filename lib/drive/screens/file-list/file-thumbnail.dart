import 'dart:io';
import 'package:bedrive/drive/http/file-entries-api.dart';
import 'package:bedrive/drive/screens/file-list/file-icon-colors.dart';
import 'package:bedrive/drive/screens/file-preview/file-preview-state.dart';
import 'package:bedrive/drive/screens/search/search-file-types.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

enum FileThumbnailSize {
  tiny,
  small,
  big,
}

class FileThumbnail extends StatelessWidget {
  FileThumbnail(this.fileEntry, {required this.size});

  final FileEntry? fileEntry;
  final FileThumbnailSize size;

  SvgPicture _svgIcon(FileEntry entry) {
    String? type = entry.type;
    if (type == null && entry.mime != null) {
      type = entry.mime!.split('/')[0];
    }

    return getFileTypeImage(type, size: size);
  }

  @override
  Widget build(BuildContext context) {
    final fileEntryApi = context.select((DriveState s) => s.api);
    final width = size == FileThumbnailSize.big ? double.infinity : 30.0;
    final imageWidget = fileEntry!.type == 'image'
      ? getImageFileThumbnail(fileEntry!, context, api: fileEntryApi, width: width)
      : _svgIcon(fileEntry!);
    return imageWidget;
  }
}

Widget getImageFileThumbnail(FileEntry fileEntry, BuildContext context, {required FileEntriesApi api, double? width}) {
  String? url = api.previewUrl(fileEntry);
  final fit = BoxFit.cover;
  if (fileEntry.thumbnail != null) {
    String separator = url!.contains('?') ? '&' : '?';
    url += separator + 'thumbnail=true';
  }

  Image placeholder = Image(image: AssetImage('assets/images/default-image.jpg'), fit: fit, width: width);
  if (fileEntry.mime!.contains('svg')) {
    return SvgPicture.network(url!, fit: fit, width: width, placeholderBuilder: (_) => placeholder);
  } else {
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      width: width,
      errorWidget: (bc, url, err) {
        final previewState = context.read<FilePreviewState>();
        return FutureBuilder(
          future: previewState.getLocallyStoredFile(context, entry: fileEntry),
          builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
            if (snapshot.hasData) {
              return Image(image: FileImage(snapshot.data!), fit: fit, width: width);
            } else {
              return placeholder;
            }
          }
        );
      },
    );
  }
}

SvgPicture getFileTypeImage(String? type, {FileThumbnailSize? size, double? sizeInPixels}) {
  if (type == null || ! SEARCH_FILE_TYPES.keys.contains(type)) {
    type = 'default';
  }
  final iconName = '${ReCase(type).paramCase}-file-custom';

  if (sizeInPixels == null) {
    if (FileThumbnailSize.tiny == size) {
      sizeInPixels = 17;
    } else if (FileThumbnailSize.small == size) {
      sizeInPixels = 24;
    } else {
      sizeInPixels = 74;
    }
  }

  return SvgPicture.asset(
      'assets/icons/$iconName.svg',
      width: sizeInPixels,
      height: sizeInPixels,
      color: FILE_ICON_COLORS[type],
  );
}