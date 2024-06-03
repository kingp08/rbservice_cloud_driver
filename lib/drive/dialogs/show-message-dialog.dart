import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';

showMessageDialog(BuildContext context, String? message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: text(message, singleLine: false),
        contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
        actions: [
          TextButton(
            child: text('Continue'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}