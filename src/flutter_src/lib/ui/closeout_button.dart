import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

// Closeout button for dialogs windows
Widget dialogCloseOutButton(BuildContext context) {
  return Positioned( // Closeout button
    right: 0.0,
    child: GestureDetector(
      onTap: (){
        Navigator.of(context).pop();
      },
      child: const Align(
        alignment: Alignment.topRight,
        child: CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.white30,
          child: Icon(Icons.close, color: Colors.lightGreen, size: 25.0,),
        ),
      ),
    ),
  );
}
