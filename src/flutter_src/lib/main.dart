import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(MaterialApp(
  home: Home(),
));

BoxDecoration investmentBoxDecoration(Color c, Color borderC) {
  return BoxDecoration(
    border: Border.all(
      color: borderC,
      width: 1,
    ),
    color: c,
  );
}

Row investmentRow(String symbol, String buyDate, String sellDate) {
  return Row( // Convert rows to stateful objects with alterable vars
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(0.0),
            decoration: investmentBoxDecoration(Colors.lightGreen, Colors.black),
            child: Text(
                symbol,
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          )
      ),
      Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(0.0),
            decoration: investmentBoxDecoration(Colors.lightGreen, Colors.black),
            child: Text(
              buyDate,
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          )
      ),
      Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(0.0),
            decoration: investmentBoxDecoration(Colors.lightGreen, Colors.black),
            child: Text(
              sellDate,
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
      ),
    ],
  );
}

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          //Expanded(flex: 3, child: Image.asset('assets/alpha1.png')),
          Expanded(
            flex: 2, // Portion of width we want it to take up '3/6'
            child: Center(
              child: Container(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                //color: Colors.cyan,
                child: Column(
                  children: <Widget>[ // Where Investments live...
                    investmentRow('AAPL', '01/04/2021', '11/12/2021'),
                    investmentRow('AMZN', '01/04/2021', '11/12/2021'),
                    investmentRow('VTI', '01/04/2021', '11/12/2021'),
                    investmentRow('BTC-USD', '01/04/2021', '11/12/2021'),
                  ],
                )
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: const BenchmarkDropdown(),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
              ),
            )
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                //padding: EdgeInsets.all(10.0),
                //color: Colors.lightGreen,
                child: TextButton(
                  onPressed: () {print("Computing Alpha Return");},
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.green,
                    shadowColor: Colors.black,
                    elevation: 5,
                    padding: const EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: const Text(
                      'Compute Alpha Return',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                        //fontFamily: 'Merriweather',
                      ),
                  ),
                ),
              ),
            ),
          ),
        ]
      ),
      /*floatingActionButton: const FloatingActionButton(
        child: Text('click'),
        onPressed: null,
        backgroundColor: Colors.lightGreen,
      ),*/
    backgroundColor: Colors.black,
    );
  }
}

class BenchmarkDropdown extends StatefulWidget {
  const BenchmarkDropdown({Key? key}) : super(key: key);

  @override
  State<BenchmarkDropdown> createState() => _BenchmarkDropdown();
}

class _BenchmarkDropdown extends State<BenchmarkDropdown> {
  String dropdownValue = 'S&P500';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 28,
      iconEnabledColor: Colors.black,
      elevation: 8,
      style: const TextStyle(color: Colors.green),
      borderRadius: BorderRadius.circular(10.0),
      dropdownColor: Colors.green,
      underline: Container (
        height: 2,
        color: Colors.black,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
          print("New Benchmark Selected");
          //Set investment benchmark job to be run against
        });
      },
      items: <String>['S&P500', 'DJI', 'NASDAQ', 'BTC-USD']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
                backgroundColor: Colors.green,
                //fontFamily: 'Merriweather',
              )
          ),
        );
      }).toList(),
    );
  }
}
