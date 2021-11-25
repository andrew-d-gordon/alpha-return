import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:date_format/date_format.dart';

void main() => runApp(MaterialApp(
  home: Home(),
));

// Implement +INV Button and Edit Invs Button

// select all/deselect, remember cache even when scrolling far off (listtile cacherecall?)

// Add closeout button for investment input section, same wit edit invs, clear inv to be added/del'd when
// close out pressed

// Dart with firebase, see if python backend possible for computing alpha return

// If python not viable as backend, see if dart has built in api calls available for market data

// Flutter integration with firebase to store user info/market data into firestore

// Remember investment sets

// Color pallette wheel


BoxDecoration investmentBoxDecoration(Color c, Color borderC) { // Box Decoration Widget
  return BoxDecoration(
    border: Border.all(
      color: borderC,
      width: 1,
    ),
    color: c,
  );
}

Row investmentRow(String symbol, String buyDate, String sellDate) { // Create investment row
  return Row( // Convert rows to stateful objects with alterable vars
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      const Expanded(
          flex: 2,
          child: InvestmentCheckBox(),
      ),
      Expanded(
          flex: 5,
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
          flex: 5,
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
          flex: 5,
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

List<List<String>> investments = [
  /*['AAPL', '01/04/2021', '11/12/2021'],
  ['AMZN', '01/04/2021', '11/12/2021'],
  ['VTI', '01/04/2021', '11/12/2021'],
  ['BTC-USD', '01/04/2021', '11/12/2021'],
  ['AAPL', '01/06/2021', '11/15/2021'],
  ['AMZN', '01/06/2021', '11/15/2021']*/];

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<Row> investmentRows = [for (var i in investments) investmentRow(i[0], i[1], i[2])];

  refresh() {setState(() {});} // Refresh Callback for descendant widgets

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alpha Return'),
        centerTitle: true,
        backgroundColor: const Color(0xff66b366),
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
                child: ListView(
                  padding: const EdgeInsets.all(1.0),
                  children: <Widget>[ // Where Investments live...
                    for (var r in investmentRows) r,
                  ],
                  scrollDirection: Axis.vertical,
                )
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: const BenchmarkDropdown(),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 60,
                    alignment: Alignment.center,
                    child: DialogExample(investmentRows, refresh),
                  ),
                ],
              )
            )
          ),
          Expanded(
            flex: 1,
            child: Center(
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
        ]
      ),
    backgroundColor: Colors.white,
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

class InvestmentCheckBox extends StatefulWidget { // Investment Checkbox class
  const InvestmentCheckBox({Key? key}) : super(key: key);

  @override
  _InvestmentCheckBoxState createState() => _InvestmentCheckBoxState();
}

class _InvestmentCheckBoxState extends State<InvestmentCheckBox> {
  bool checkedValue = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CheckboxListTile(
        value: checkedValue,
        checkColor: Colors.black,
        contentPadding: const EdgeInsets.all(1.0),
        dense: false,
        activeColor: Colors.greenAccent,
        tileColor: Colors.white,
        selectedTileColor: Colors.green,
        onChanged: (newValue) {
          setState(() {
            checkedValue = newValue!;
          });
        },
      ),
    );
  }
}

// Dialog Box for Creating Investment Row
class DialogExample extends StatefulWidget {
  //const DialogExample(List<Row> investmentRows, {Key? key}) : super(key: key);
  final List<Row> investmentRows;
  final Function() notifyParent;
  const DialogExample(this.investmentRows, this.notifyParent);
  //const DialogExample({Key? key, this.investmentRows, this.notifyParent}) : super(key: key);

  @override
  _DialogExampleState createState() => _DialogExampleState();
}

class _DialogExampleState extends State<DialogExample> {
  String _ticker = "";
  String _buyDate = "";
  String _sellDate = "";
  final TextEditingController _t = TextEditingController();
  final TextEditingController _b = TextEditingController();
  final TextEditingController _s = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FloatingActionButton(onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "Ticker Symbol",
                          border: OutlineInputBorder(),
                        ),
                        controller: _t,
                      ),
                      TextField(
                        decoration: const InputDecoration(
                            hintText: "Buy Date as 'dd/mm/yy'",
                            border: OutlineInputBorder(),
                        ),
                        focusNode: AlwaysDisabledFocusNode(), // Shift focus to Datepicker
                        controller: _b,
                        onTap: () {
                          //_b.text = DateTime.now().toString();
                          _b.text = formatDate(DateTime.now(), [mm, '/', dd, '/', yyyy]);
                          _selectDate(context, _b);
                        }
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "Sell Date as 'dd/mm/yy'",
                          border: OutlineInputBorder(),
                        ),
                        focusNode: AlwaysDisabledFocusNode(), // Shift focus to Datepicker
                        controller: _s,
                        onTap: () {
                          //_s.text = DateTime.now().toString();
                          _s.text = formatDate(DateTime.now(), [mm, '/', dd, '/', yyyy]);
                          _selectDate(context, _s);
                        }
                      ),
                      TextButton(
                        child: const Text("Add Investment"),
                        onPressed: (){
                          setState((){
                            _ticker = _t.text;
                            _buyDate = _b.text;
                            _sellDate= _s.text;
                            widget.investmentRows.add(investmentRow(_ticker, _buyDate, _sellDate));
                            widget.notifyParent(); // Notify parent to update rows
                          });
                          Navigator.pop(context); // if vars set correct
                          print("$_ticker $_buyDate $_sellDate");

                          // Reset text in controllers
                          _t.text = _b.text = _s.text = '';
                        },
                      ),
                    ],
                  )
                );
              },
            );
          },
          child: const Text("+Inv"),
          backgroundColor: Colors.lightGreen,
          hoverColor: Colors.greenAccent,
          hoverElevation: 10.0,
        )
      ])
    );
  }

  _selectDate(BuildContext context, TextEditingController t) { // Date picker
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 500,
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            SizedBox(
              height: 400,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (val) {
                  setState(() {
                    t.text = formatDate(val, [mm, '/', dd, '/', yyyy]);
                  });
                }),
            ),
            // Close the modal
            CupertinoButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        )
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
