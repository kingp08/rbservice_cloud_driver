import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.name,
  }) : super(key: key);
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 16),
      child: text(name, style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).primaryColor), uppercase: true),
    );
  }
}
