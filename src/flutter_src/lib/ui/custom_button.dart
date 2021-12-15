// Remote Imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Plain custom button for closing dialog
Center customButton(BuildContext context, String text, TextStyle ts) {
  return Center(
    child: TextButton( // Add Exit button for the bottom
      child: Text(text, style: ts),
      onPressed: () {
        // Notify parent to update rows
        Navigator.pop(context);
      },
    ),
  );
}