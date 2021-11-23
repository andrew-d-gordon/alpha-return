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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(flex: 3, child: Image.asset('assets/alpha1.png')),
          Expanded(
            flex: 1, // Portion of width we want it to take up '3/6'
            child: Container(
              padding: EdgeInsets.all(30.0),
              color: Colors.cyan,
              child: Text('1'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(30.0),
              color: Colors.red,
              child: Text('2'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(30.0),
              color: Colors.pink,
              child: Text('3'),
            ),
          ),
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
