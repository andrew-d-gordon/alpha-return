import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Horizontal Spacing
        crossAxisAlignment: CrossAxisAlignment.start, // Vertical Spacing
        children: <Widget>[
          Text('Hello, World'),
          FlatButton(
            onPressed: () {},
            color: Colors.black26,
            child: Text('Click Me'),
          ),
          Container(
            color: Colors.cyan,
            padding: EdgeInsets.all(30.0),
            child: Text('Inside container'),
          )
        ]
      ),
      floatingActionButton: const FloatingActionButton(
        child: Text('click'),
        onPressed: null,
        backgroundColor: Colors.lightGreen,
      ),
    );
  }
}
