import 'package:bedrive/drive/screens/file-preview/file-preview-state.dart';
import 'package:bedrive/drive/screens/file-preview/generic-file-preview.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoFilePreview extends StatefulWidget {
  const VideoFilePreview(
    this.fileEntry, {
    Key? key,
  }) : super(key: key);

  final FileEntry fileEntry;

  @override
  State<StatefulWidget> createState() {
    return _VideoFilePreviewState();
  }
}

class _VideoFilePreviewState extends State<VideoFilePreview> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool loading = true;

  @override
  void initState() {
    this._initPlayer();
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    if (_chewieController != null) {
      _chewieController!.dispose();
    }
    super.dispose();
  }

  Future<void> _initPlayer() async {
    try {
      await _initController();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        allowPlaybackSpeedChanging: false,
      );
    } catch (e) {
      //
    }
    setState(() => loading = false);
  }

  _initController() async {
    final previewState = context.read<FilePreviewState>();
    final localFile = await previewState.getLocallyStoredFile(context);
    if (localFile != null) {
      _videoPlayerController = VideoPlayerController.file(localFile);
    } else {
      _videoPlayerController = VideoPlayerController.network(
          context.read<DriveState>().api.previewUrl(widget.fileEntry)!);
    }
    await _videoPlayerController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _getPlayerWidget(),
    );
  }

  _getPlayerWidget() {
    if (loading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          text('Loading'),
        ],
      );
    } else if (_chewieController == null) {
      return GenericFilePreview(widget.fileEntry);
    } else if (widget.fileEntry.type == 'audio') {
      return Container(
        child: Chewie(controller: _chewieController!),
        height: 200,
        padding: EdgeInsets.all(10),
      );
    } else {
      return AspectRatio(
        aspectRatio: _videoPlayerController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      );
    }
  }
}
