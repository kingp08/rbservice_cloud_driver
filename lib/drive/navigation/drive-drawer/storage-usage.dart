import 'package:bedrive/drive/state/space-usage/space-usage-state.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StorageUsage extends StatefulWidget {
  @override
  _StorageUsageState createState() => _StorageUsageState();
}

class _StorageUsageState extends State<StorageUsage> {
  @override
  void initState() {
    super.initState();
    context.read<SpaceUsageState>().sync();
  }

  @override
  Widget build(BuildContext context) {
    final usage = context.select((SpaceUsageState s) => s.usage);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: usage.usedPercentage / 100),
        SizedBox(height: 7),
        Directionality(
            textDirection: TextDirection.ltr,
            child: text(
              ':used of :available used',
              color: Theme.of(context).textTheme.caption!.color,
              replacements: {
                'used': usage.humanReadableUsed,
                'available': usage.humanReadableAvailable
              },
            ),
        )
      ],
    );
  }
}