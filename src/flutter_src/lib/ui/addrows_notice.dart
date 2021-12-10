import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddRowsNotice extends StatelessWidget {
  const AddRowsNotice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
            'Use +INV button below to add investments.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey,
                fontSize: 22.0, fontWeight:
                FontWeight.bold)
        )
    );
  }
}