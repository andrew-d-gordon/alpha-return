// Remember CheckboxListTile status with scrolling demo.
// Currently utilizes rows in implementation.
// This can be cut down to maintain a single checkbox list tile.

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  home: Home(),
));

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // Refresh Callback for descendant widgets (if checkboxes are generated in seperate widget)
  refresh() {setState(() {});}
  // Rows with checkbox title and check value
  // Must update second value in entry to maintain check status while scrolling
  List<List> rowData = [
    ['row1', true], ['row2', false], ['row3', false],
    ['row4', false], ['row5', false], ['row6', false],
    ['row7', false], ['row8', false], ['row9', false],
    ['row10', false], ['row11', false], ['row12', false],
    ['row13', false], ['row14', false], ['row15', false],
    ['row16', false], ['row17', false], ['row18', false],
    ['row19', false], ['row20', false], ['row21', false],
    ['row22', false], ['row23', false], ['row24', false]];
  List<Row> rows = []; // Holds row objects generated from rowData (with checkboxes)
  int row = 0;
  int rowCount = 0;

  @override
  Widget build(BuildContext context) {

    rows = []; // Refresh rows
    for (int i=0; i<rowData.length; i++) { // Init/refresh row widgets
      rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded (
              child: CheckboxListTile(
                  value: rowData[i][1] as bool, // Check value
                  title: SizedBox(
                      width: 100,
                      child: Text(rowData[i][0], style: const TextStyle(fontSize: 50))
                  ), // Title for check box
                  checkColor: Colors.black,
                  dense: false,
                  onChanged: (newValue) { // On click of check box
                    setState(() {
                      print("Checkbox clicked");
                      rowData[i][1] = newValue; // Update value in the RowData list
                    });
                  }
              ),
            )
          ]
      ));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Remember Checkboxes Demo'),
          centerTitle: true,
          backgroundColor: const Color(0xff66b366),
        ),
        body: Column (
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: ListView(
                    children: <Widget>[for (var i in rows) i,] // Fill in rows
                ),
              )
            ]
        )
    );
  }
}