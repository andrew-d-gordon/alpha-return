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
        backgroundColor: Colors.green,
      ),
      body: Center(
        /*child: Text(
          'hello brother',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.grey,
            fontFamily: 'Merriweather',
          )
        ),*/
        child: IconButton(
          onPressed: () {print('you clicked me');},
          icon: Icon(Icons.add),
          color: Colors.lightGreen,
        ),
      ),
      floatingActionButton: const FloatingActionButton(
        child: Text('click'),
        onPressed: null,
        backgroundColor: Colors.lightGreen,
      ),
    );
  }
}
