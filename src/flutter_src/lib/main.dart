import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:date_format/date_format.dart';
import 'package:fin_quote/fin_quote.dart';
import 'package:http/http.dart' as http;

int secondsInADay = 86400; // Used for adding secondsInADay to initial time stamp

// Find closing prices of a supplied investment on a specified date
Future<double> retrieveMarketValue(String ticker, String dateStr) async {
  double dateClosePrice = 0.0;
  List dateSplit = dateStr.split('/');
  DateTime date = DateTime(int.parse(dateSplit[2]), int.parse(dateSplit[0]), int.parse(dateSplit[1]));
  int dateUnixStamp = date.toUtc().millisecondsSinceEpoch ~/ 1000;
  print("============================================\nTicker requested is: $ticker on date: $date\n");
  //Example url which is produced
  //https://query2.finance.yahoo.com/v8/finance/chart/AAPL?symbol=AAPL&period1=1636704000&period2=1636790400&interval=1d&events=history
  //String url = 'https://$authority/$unencodedPath/$ticker?&symbol=$ticker&period1=$dateUnixStamp&period2=${dateUnixStamp+secondsInADay}&interval=1d&events=history';

  // Build URI paremeters out
  String authority = 'query2.finance.yahoo.com';
  String unencodedPath = 'v8/finance/chart/$ticker';
  var queryParemeters = {
    'symbol': ticker, // Investment Symbol e.g. 'AAPL', '^GSPC', 'BTC-USD'
    'period1': dateUnixStamp.toString(), // Start Date
    'period2': (dateUnixStamp+secondsInADay).toString(), // End Date
    'interval': '1d',
    'events': 'history'
  };

  Uri uri = Uri.https(authority, unencodedPath, queryParemeters); // Build URI
  http.Response res = await http.get(uri); // Run Get Request for Investment Data
  if (res.statusCode == 200) { // If response is valid, parse body data for price
    Map<String, dynamic> body = jsonDecode(res.body);
    //print('This is body returned:\n==========\n$body');

    // Extract quote dict with pricing info for desired date
    Map<String, dynamic> quote = body['chart']['result'][0]['indicators']['quote'][0];
    print('This is quote returned:\n$quote\n\n');
    dateClosePrice = quote['close'][0];
  } else {
    print('Response was invalid with status code: ${res.statusCode}');
  }

  return dateClosePrice;
}

void main() => runApp(MaterialApp(
  home: Home(),
));

// Run compute alpha return calculations, perhaps modularize main.dart to multiple files

// Make a dialog example clone but for editing fields of a row (must know row id) ?

// investment input section/make modal area smaller
// clear inv to be added/del'd when close out pressed

// Dart with firebase, see if python backend possible for computing alpha return

// If python not viable as backend, see if dart has built in api calls available for market data

// Flutter integration with firebase to store user info/market data into firestore

// Remember investment sets

// Color scheme modifier

BoxDecoration investmentBoxDecoration(Color c, Color borderC) { // Box Decoration Widget
  return BoxDecoration(
    border: Border.all(
      color: borderC,
      width: 1,
    ),
    color: c,
  );
}

// Stateful Widgets
// the state of the widget can change over time

// Stateless Widgets
// the state of the widget cannot change over time

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // Refresh Callback for descendant widgets to notify parent of updated values
  refresh() {setState(() {});}

  // Variable data utilized to generate investment rows and their state variables
  // investments has an investment specified as: [Symbol, BuyDate, SellDate, Selected (t/f)]
  List<List> investments = [
    ['AAPL', '01/04/2021', '11/12/2021', false],
    ['AMZN', '01/04/2021', '11/12/2021', false],
    ['VTI', '01/04/2021', '11/12/2021', true],
    ['BTC-USD', '01/04/2021', '11/12/2021', false],
    ['AAPL', '01/06/2021', '11/15/2021', false],
    ['AMZN', '01/06/2021', '11/15/2021', false]];

  // Holds investmentRows built from investments
  List<InvestmentRow> investmentRows = [];

  @override
  void initState() { // Would ideally fill investments with saved investments
    for (int i=0; i<investments.length; i++) { // Load Investment rows/refresh
      List inv = investments[i];
      investmentRows.add(InvestmentRow(symbol: inv[0],
          buyDate: inv[1],
          sellDate: inv[2],
          notify: refresh,
          investments: investments,
          row: i));
    }
  }

  @override
  Widget build(BuildContext context) {
    investmentRows = []; // Refresh investmentRows
    for (int i=0; i<investments.length; i++) { //Refresh investment data
      List inv = investments[i];
      investmentRows.add(InvestmentRow(symbol: inv[0],
          buyDate: inv[1],
          sellDate: inv[2],
          notify: refresh,
          investments: investments,
          row: i));
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            flex: 4, // Portion of width we want it to take up '3/6'
            child: Center(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 2.0, color: Colors.black),
                  )
                ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 70,
                        height: 57,
                        alignment: Alignment.center,
                        child: DialogExample(investments: investments, notify: refresh),
                      ),
                      Container(
                        width: 70,
                        height: 60,
                        alignment: Alignment.center,
                        child: DeleteInvestmentsButton(investments: investments, notify: refresh),
                      )
                    ],
                  ),
                ],
              )
            )
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: TextButton(
                onPressed: () async {
                  print("Computing Alpha Return");
                  // Want to queue computing for alpha return of each row in
                  // investments with investment[3] set to true
                  List symbols = [];
                  List buyPrices = [];
                  List sellPrices = [];
                  for (int i=0; i<investments.length; i++) {
                    if (investments[i][3]) { // If investment selected, compute annual return
                      List inv = investments[i];
                      // Get buy and sell closing prices
                      symbols.add(inv[0]);
                      double buyPrice = await retrieveMarketValue(inv[0], inv[1]);
                      double sellPrice = await retrieveMarketValue(inv[0], inv[2]);
                      buyPrices.add(buyPrice);
                      sellPrices.add(sellPrice);
                    }
                  }
                  for (var i in buyPrices) print("Entry in Buy Prices: $i");
                  for (var j in sellPrices) print("Entry in Sell Prices: $j");

                  // We would then like to build out a modified Dialog Example
                  // with annual return of each investment, of the benchmark, and
                  // the inherent alpha return.

                  // Weighted Annual return would be computed as follows (would need % of portfolio metric on investments)
                  // (percentage_i1*i1_annual_return + percentage_i2*i2_annual_return + ... + percentage_in*in_annual_return)
                  // Where i(1->n) is a selected investment with an associated annual return and percentage of portfolio specified
                },
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
                    fontSize: 28,
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

// Benchmark Dropdown Widget
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

// Investment Row Widget
class InvestmentRow extends StatefulWidget {
  final String symbol;
  final String buyDate;
  final String sellDate;
  final List<List> investments;
  final int row;
  final Function() notify;
  const InvestmentRow({
    Key? key,
    required this.symbol,
    required this.buyDate,
    required this.sellDate,
    required this.notify,
    required this.investments,
    required this.row}) : super(key: key);

  @override
  _InvestmentRowState createState() => _InvestmentRowState();
}

class _InvestmentRowState extends State<InvestmentRow> {

  @override
  Widget build(BuildContext context) {
    return Row( // Convert rows to stateful objects with alterable vars
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: InvestmentCheckBox(notify: widget.notify,
            investments: widget.investments,
            row: widget.row,),
        ),
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.all(0.0),
            decoration: investmentBoxDecoration(Colors.lightGreen, Colors.black),
            child: Text(
              widget.symbol,
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
              widget.buyDate,
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
              widget.sellDate,
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

// Investment Row CheckboxListTile Widget
class InvestmentCheckBox extends StatefulWidget { // Investment Checkbox class
  final Function() notify;
  final List<List> investments;
  final int row;
  const InvestmentCheckBox({Key? key,
    required this.notify,
    required this.investments,
    required this.row}) : super(key: key);

  @override
  _InvestmentCheckBoxState createState() => _InvestmentCheckBoxState();
}

class _InvestmentCheckBoxState extends State<InvestmentCheckBox> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CheckboxListTile(
        value: widget.investments[widget.row][3],
        checkColor: Colors.black,
        contentPadding: const EdgeInsets.all(1.0),
        dense: false,
        activeColor: Colors.greenAccent,
        tileColor: Colors.white,
        selectedTileColor: Colors.green,
        onChanged: (newValue) {
          setState(() {
            widget.investments[widget.row][3] = newValue; // Update value in list
            // Notify parent to take account of checkboxes
            widget.notify();
          });
        },
      ),
    );
  }
}

// Error check +Inv investment, return error string, "" if no error
String errorCheckInvestment(String ticker, String buyDateStr, String sellDateStr) {
  String nullError = "Bad input, each attribute must be filled";
  String badCharactersError = "Bad input, invalid characters in ticker";
  String offsetDateError = "Bad input, buy date must occur before the sell date";
  String sameDateError = "Bad input, buy and sell dates must be different";

  if (ticker == '' || buyDateStr == '' || sellDateStr == '') { // Null input check
    // Show alert dialog with null input message
    return nullError;
  }

  List buyDateSplit = buyDateStr.split('/'); // Split buyDateStr for DateTime creation
  List sellDateSplit = sellDateStr.split('/'); // Split sellDateStr for DateTime creation
  DateTime buyDate = DateTime(int.parse(buyDateSplit[2]), // Create DateTime buyDate
      int.parse(buyDateSplit[0]),
      int.parse(buyDateSplit[1]));
  DateTime sellDate = DateTime(int.parse(sellDateSplit[2]), // Create DateTime sellDate
      int.parse(sellDateSplit[0]),
      int.parse(sellDateSplit[1]));

  if (!(RegExp(r'^[A-Za-z^]+$').hasMatch(ticker))) { // Valid ticker characters check
    return badCharactersError;
  } else if (buyDate.compareTo(sellDate) > 0) { // If buyDate is after sellDate
    // Show alert dialog with invalid dates message
    return offsetDateError;
  } else if (buyDate.compareTo(sellDate) == 0) { // If buyDate==sellDate
    // Show alert dialog notifying user of same buy and sell date
    return sameDateError;
  } else {
    return "";
  }
}

// Button and Dialog Modal for Creating Investment Row Widget
class DialogExample extends StatefulWidget {
  //final List<InvestmentRow> investmentRows;
  final List<List> investments;
  final Function() notify;
  const DialogExample({Key? key,
    required this.investments, required this.notify,}) : super(key: key);

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

  double dialogFontSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FloatingActionButton(onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return SizedBox(
                  width: 100,
                  height: 40,
                  child: Dialog(
                    elevation: 10,
                    insetAnimationCurve: Curves.easeInOutCubicEmphasized,
                    insetAnimationDuration: const Duration(seconds: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextField(
                          style: TextStyle(fontSize: dialogFontSize),
                          decoration: const InputDecoration(
                            hintText: "Ticker Symbol",
                            border: OutlineInputBorder(),
                          ),
                          controller: _t,
                        ),
                        TextField(
                          style: TextStyle(fontSize: dialogFontSize),
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
                          style: TextStyle(fontSize: dialogFontSize),
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
                          child: Text("Add Investment", style: TextStyle(fontSize: dialogFontSize)),
                          onPressed: () {
                            bool validInvestment = true;
                            String error = "";
                            setState(() {
                              // Error check investment
                              error = errorCheckInvestment(_t.text, _b.text, _s.text);
                              if (error != "") {
                                validInvestment = false;
                                return;
                              }

                              _ticker = _t.text;
                              _buyDate = _b.text;
                              _sellDate= _s.text;

                              widget.investments.add([
                                _ticker,
                                _buyDate,
                                _sellDate,
                                true]);
                              widget.notify(); // Notify parent to update rows
                            });

                            if (validInvestment) {
                              // Pop Dialog Window
                              Navigator.pop(context);
                              print("New row: $_ticker $_buyDate $_sellDate");
                              // Reset text in controllers
                              _t.text = _b.text = _s.text = '';
                            } else {
                              // Display error message
                              print(error);
                            }
                          },
                        ),
                      ],
                    )
                  ),
                );
              },
            );
          },
          child: const Text("+INV"),
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

// Disable focus node function for focusing date picker instead of keyboard
class AlwaysDisabledFocusNode extends FocusNode { // Helps dismiss keyboard for TextField
  @override
  bool get hasFocus => false;
}

// Delete Investments Button Widget
class DeleteInvestmentsButton extends StatefulWidget {
  final List<List> investments;
  final Function() notify;
  const DeleteInvestmentsButton({Key? key,
    required this.investments,
    required this.notify}) : super(key: key);

  @override
  _DeleteInvestmentsButtonState createState() => _DeleteInvestmentsButtonState();
}

class _DeleteInvestmentsButtonState extends State<DeleteInvestmentsButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(onPressed: () {
      setState(() {
        widget.investments.removeWhere((row) => row[3] == true); // Remove selected rows
        widget.notify(); // Notify parent of updates
      });
    },
      child: const Icon(
          Icons.delete_forever_rounded,
        size: 40,
      ),
      backgroundColor: Colors.lightGreen,
      hoverColor: Colors.greenAccent,
      hoverElevation: 12.0,
    );
  }
}


