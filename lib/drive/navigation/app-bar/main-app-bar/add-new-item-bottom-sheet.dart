import 'dart:io';

import 'package:bedrive/drive/context-actions/context-menu-sizes.dart';
import 'package:bedrive/drive/dialogs/crupdate-entry-dialog.dart';
import 'package:bedrive/drive/dialogs/loading-dialog.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/root-navigator-key.dart';
import 'package:bedrive/transfers/transfers-screen/transfers-screen.dart';
import 'package:bedrive/utils/text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddNewItemBottomSheet extends StatelessWidget {
  AddNewItemBottomSheet(this.driveState);
  final DriveState driveState;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      ListTile(
          leading: Icon(Icons.create_new_folder_outlined),
          title: text('New Folder'),
          onTap: () async {
            Navigator.of(context).pop();
            showCrupdateEntryDialog(context, fileType: 'folder');
          })
    ];

    // Photo gallery on iOS
    if (Platform.isIOS) {
      children.add(ListTile(
        leading: const Icon(Icons.photo_library_outlined),
        title: text('Upload Image'),
        onTap: () async {
          _pickImageOrVideo(context, 'image', ImageSource.gallery);
          Navigator.of(context).pop();
        },
      ));
      children.add(ListTile(
        leading: const Icon(Icons.video_collection_outlined),
        title: text('Upload Video'),
        onTap: () async {
          _pickImageOrVideo(context, 'video', ImageSource.gallery);
          Navigator.of(context).pop();
        },
      ));
    }

    // Pick file from file system
    children.add(ListTile(
      leading: const Icon(Icons.upload_file),
      title: text(Platform.isAndroid ? 'Upload Files' : 'Browse'),
      onTap: () async {
        Future.delayed(Duration(milliseconds: 300), () {
          LoadingDialog.show(message: trans('Preparing to upload files'));
        });
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
        );
        LoadingDialog.hide();
        Navigator.of(context).pop();
        if (result != null) {
          driveState.uploadFiles(result.paths);
          if (Platform.isIOS) {
            Navigator.of(context).pushNamed(TransfersScreen.ROUTE);
          }
        }
      },
    ));

    // Take photo / video
    children.addAll([
      ListTile(
        leading: const Icon(Icons.add_a_photo_outlined),
        title: text('Take Photo'),
        onTap: () async {
          _pickImageOrVideo(context, 'image', ImageSource.camera);
          Navigator.of(context).pop();
        },
      ),
      ListTile(
        leading: const Icon(Icons.video_call_outlined),
        title: text('Record Video'),
        onTap: () async {
          _pickImageOrVideo(context, 'video', ImageSource.camera);
          Navigator.of(context).pop();
        },
      ),
    ]);

    return Container(
      height: (CONTEXT_MENU_ITEM_HEIGHT * children.length).toDouble(),
      child: ListView(
        children: children,
      ),
    );
  }

  _pickImageOrVideo(
      BuildContext context, String type, ImageSource source) async {
    final pickedFile = type == 'image'
        ? await ImagePicker().pickImage(source: source)
        : await ImagePicker().pickVideo(source: source);

    if (pickedFile != null) {
      driveState.uploadFiles([pickedFile.path]);
      if (Platform.isIOS) {
        rootNavigatorKey.currentState!.pushNamed(TransfersScreen.ROUTE);
      }
    }
  }
}
