import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Home(),
));

// Stateful Widgets
// the state of the widget can change over time

// Stateless Widgets
// the state of the widget cannot change over time

class Home extends StatelessWidget {

  // Used to say the build function will override our build
  // instead of stateless widget super class build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alpha Return'),
        centerTitle: true,
        backgroundColor: Color(0xff66b366),
      ),
      body: /*Padding(
        padding: EdgeInsets.all(30.0),
        child: Text('Hello'),
      ),*/
      Container(
        padding: EdgeInsets.all(20.0),
        margin: EdgeInsets.all(30.0),
        color: Colors.green,
        child: Text('Hello')
      ),
      floatingActionButton: const FloatingActionButton(
        child: Text('click'),
        onPressed: null,
        backgroundColor: Colors.lightGreen,
      ),
    );
  }
}
