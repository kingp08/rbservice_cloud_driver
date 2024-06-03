import 'package:bedrive/transfers/transfer-queue/file-transfer.dart';
import 'package:bedrive/transfers/transfer-queue/transfer-queue.dart';
import 'package:bedrive/utils/text.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransfersScreenListTile extends StatelessWidget {
  TransfersScreenListTile(this.transfer, {Key? key}) : super(key: key);
  final FileTransfer transfer;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 16),
      onTap: transfer.status == TransferQueueStatus.completed ? null : () => _toggleTransfer(transfer, context),
      leading: Container(
        width: 40,
        alignment: Alignment.center,
        child: _ProgressIndicator(transfer.fingerprint),
      ),
      title: Text(transfer.displayName!),
      subtitle: _TransferStatus(transfer.fingerprint),
      trailing: IconButton(
        icon: const Icon(Icons.close_outlined),
        onPressed: () => context.read<TransferQueue>().cancelTransfer(transfer.fingerprint),
      ),
    );
  }
  
  _toggleTransfer(FileTransfer transfer, BuildContext context) {
    if (transfer.status == TransferQueueStatus.inProgress) {
      context.read<TransferQueue>().pauseTransfer(transfer.fingerprint);
    } else if (transfer.status == TransferQueueStatus.paused) {
      context.read<TransferQueue>().resumeTransfer(transfer.fingerprint);
    } else if (transfer.status == TransferQueueStatus.error) {
      context.read<TransferQueue>().resumeTransfer(transfer.fingerprint, restart: true);
    }
  }
}

class _TransferStatus extends StatelessWidget {
  const _TransferStatus(this.fingerprint, {Key? key}) : super(key: key);
  final String? fingerprint;

  @override
  Widget build(BuildContext context) {
    final status = context.select((TransferQueue s) => s.queue[fingerprint]?.status) ?? TransferQueueStatus.inProgress;
    final bytesLeft = context.select((TransferQueue s) => s.queue[fingerprint]?.progress?.bytesLeft) ?? 0;
    final error = context.select((TransferQueue s) => s.queue[fingerprint]?.backendError) ?? null;

    switch(status) {
      case TransferQueueStatus.inProgress:
        if (bytesLeft == 0)  {
          return text('Processing...');
        }
        return text(
          ':bytes left',
          replacements: {'bytes': filesize(bytesLeft)}
        );
      case TransferQueueStatus.paused:
        return text('Paused');
      case TransferQueueStatus.completed:
        return text('Completed');
      case TransferQueueStatus.error:
        String msg = error != null ? error.message! : trans('Error. Tap to retry')!;
        return Text(msg);
    }
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator(this.fingerprint, {Key? key}) : super(key: key);
  final String? fingerprint;

  @override
  Widget build(BuildContext context) {
    final status = context.select((TransferQueue s) => s.queue[fingerprint]?.status) ?? TransferQueueStatus.inProgress;
    final progress = context.select((TransferQueue s) => s.queue[fingerprint]?.progress?.percentage) ?? 0;
    Color color = status == TransferQueueStatus.error ? Theme.of(context).errorColor : Theme.of(context).primaryColor;

    return SizedBox(
      width: 26,
      height: 26,
      child:  Stack(
        children: [
          CircularProgressIndicator(
            value: status == TransferQueueStatus.completed ? 100 : (progress / 100),
            backgroundColor: color.withAlpha(100),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Align(
            alignment: Alignment.center,
            child: Icon(
              _getIcon(status),
              size: 14,
              color: color,
            ),
          )
        ],
      ),
    );
  }

  IconData _getIcon(TransferQueueStatus status) {
    switch(status) {
      case TransferQueueStatus.inProgress:
        return Icons.pause_outlined;
      case TransferQueueStatus.paused:
        return Icons.play_arrow_outlined;
      case TransferQueueStatus.completed:
        return Icons.check_outlined;
      case TransferQueueStatus.error:
        return Icons.error_outline;
    }
  }
}


