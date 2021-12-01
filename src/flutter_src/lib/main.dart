import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:fin_quote/fin_quote.dart';
import 'package:http/http.dart' as http;

// To do:
// Modularize main.dart to multiple files

// Add unique identifiers for symbols, probably just use counter as key instead of ticker
// Add error message in AddInvestmentDialog to specify why investment invalid
// Figure out how to interpolate binance/coincap market values like with yahoo
// Unrequire dependency for fin_quote

// Make a dialog example clone but for editing fields of a row (must know row id) ?

// Investment input section/make modal area smaller
// clear inv to be added/del'd when close out pressed

// Dart with firebase, see if python backend possible for computing alpha return

// If python not viable as backend, see if dart has built in api calls available for market data

// Flutter integration with firebase to store user info/market data into firestore

// Remember investment sets

// Color scheme modifier

// Time constants
int secondsInADay = 86400; // Used for adding secondsInADay to initial time stamp
double daysInAYear = 365.25;  // Used for computing annual return

// Request Headers
Map<String, String> corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  'Access-Control-Allow-Headers': '*',
  'Access-Control-Allow-Methods': '*',
  //'Access-Control-Allow-Credentials': 'true',
  'Accept': 'application/json',
};

// Formats string date of form 'mm/dd/yyyy' to DateTime
DateTime stringToDateTime(String dateStr) {
  List dateSplit = dateStr.split('/');
  return DateTime(int.parse(dateSplit[2]), int.parse(dateSplit[0]), int.parse(dateSplit[1]));
}

// Formats DateTime date to 'mm/dd/yyyy'
String dateTimeToString(DateTime date) {
  return "${date.month.toString()}/${date.day.toString()}/${date.year.toString()}";
}

// Find closing prices of a supplied investment on a specified date
Future<double> retrieveMarketValue(String ticker, String dateStr) async {
  double dateClosePrice = 0.0;
  DateTime date = stringToDateTime(dateStr);
  int dateUnixStamp = date.toUtc().millisecondsSinceEpoch ~/ 1000;
  print("============================================\nTicker requested is: $ticker on date: $date\n");
  //Example url which is produced
  //https://query2.finance.yahoo.com/v8/finance/chart/AAPL?symbol=AAPL&period1=1636704000&period2=1636790400&interval=1d&events=history
  //String url = 'https://$authority/$unencodedPath/$ticker?&symbol=$ticker&period1=$dateUnixStamp&period2=${dateUnixStamp+secondsInADay}&interval=1d&events=history';

  // Reference on utilizing cors proxy
  /*String authority = 'cors-anywhere.herokuapp.com';
  String unencodedPath = 'query2.finance.yahoo.com/v8/finance/chart/$ticker';*/
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
  print("This is uri: $uri");
  http.Response res = await http.get(uri, headers: corsHeaders); // Run Get Request for Investment Data
  if (res.statusCode == 200) { // If response is valid, parse body data for price
    Map<String, dynamic> body = jsonDecode(res.body);
    // Extract quote/adjclose dict with pricing info for desired date
    //Map<String, dynamic> quote = body['chart']['result'][0]['indicators']['quote'][0];
    //dateClosePrice = quote['close'][0];
    Map<String, dynamic> indicators = body['chart']['result'][0]['indicators'];
    print('This is indicators returned:\n$indicators\n\n');

    // Retrieve adjusted close price for investment
    Map<String, dynamic> adjCloseEntry = body['chart']['result'][0]['indicators']['adjclose'][0];
    dateClosePrice = adjCloseEntry['adjclose'][0];
  } else {
    print('Response was invalid with status code: ${res.statusCode}');
  }

  return dateClosePrice;
}

// Compute days between two dates
int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

// Round value to have specified number of places
double round(double val, int places) {
  num mod = pow(10.0, places);
  return ((val * mod).round().toDouble() / mod);
}

// Compute annual return for investment by it's buyPrice, sellPrice and date differential
double computeAnnualReturn(double buyPrice, double sellPrice, int daysDiff) {
  // Set up compound interets 'magic', daily compound interest
  num dailyCompoundInterest = pow((sellPrice/buyPrice), 1/daysDiff);

  // Compute annual return
  double annualReturn = round((dailyCompoundInterest-1)*(daysInAYear*1000000), 0);
  annualReturn /= 10000;

  return annualReturn;
}

// Computing Alpha Return for investment against benchmark
double computeAlphaReturn(double investmentReturn, double benchmarkReturn) {
  return round(investmentReturn-benchmarkReturn, 4);
}

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false, // Removes Debug Banner
  home: Home(),
));

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

  // Benchmark Investments
  Map<String, String> benchmarks = {
    "S&P500": "^GSPC",
    "Dow Jones": "^DJI",
    "NASDAQ": "^IXIC",
    "Bitcoin": "BTC-USD"
  };
  List<String> benchmark = ["S&P500"];


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
                    child: BenchmarkDropdown(benchmark: benchmark, notify: refresh),
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
                        child: AddInvestmentDialog(investments: investments, notify: refresh),
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
                  /* Want to queue computing for alpha return of each row in
                     investments with investment[3] set to true */
                  Map investmentsAnalyzed = {}; // Holds analyzed investments
                  String benchmarkTicker = benchmarks[benchmark[0]]!;
                  for (int i=0; i<investments.length; i++) {
                    // If investment selected (investments[i][3] == true), compute annual return
                    if (investments[i][3]) {
                      // Get buy and sell closing prices
                      List inv = investments[i];
                      investmentsAnalyzed[inv[0]] = {};

                      await retrieveMarketValue(inv[0], inv[1]).then((val) => { // Add error checks, continue on error, remove error prone rows/notify user
                        investmentsAnalyzed[inv[0]]['buyPrice'] = val
                      });
                      await retrieveMarketValue(inv[0], inv[2]).then((val) => {
                        investmentsAnalyzed[inv[0]]['sellPrice'] = val
                      });
                      await retrieveMarketValue(benchmarkTicker, inv[1]).then((val) => {
                        investmentsAnalyzed[inv[0]]['benchBuyPrice'] = val
                      });
                      await retrieveMarketValue(benchmarkTicker, inv[2]).then((val) => {
                        investmentsAnalyzed[inv[0]]['benchSellPrice'] = val
                      });
                      int daysDiff = daysBetween(stringToDateTime(inv[1]), stringToDateTime(inv[2]));

                      // Set Investment Analysis attributes in investmentsAnalyzed
                      investmentsAnalyzed[inv[0]]['daysDiff'] = daysDiff;
                      investmentsAnalyzed[inv[0]]['annualReturn'] = computeAnnualReturn(
                          investmentsAnalyzed[inv[0]]['buyPrice'],
                          investmentsAnalyzed[inv[0]]['sellPrice'],
                          daysDiff);

                      investmentsAnalyzed[inv[0]]['benchmark'] = benchmark[0]; // Make non null
                      investmentsAnalyzed[inv[0]]['benchmarkAnnualReturn'] = computeAnnualReturn(
                          investmentsAnalyzed[inv[0]]['benchBuyPrice'],
                          investmentsAnalyzed[inv[0]]['benchSellPrice'],
                          daysDiff);

                      investmentsAnalyzed[inv[0]]['alphaReturn'] = computeAlphaReturn(
                          investmentsAnalyzed[inv[0]]['annualReturn'],
                          investmentsAnalyzed[inv[0]]['benchmarkAnnualReturn']
                      );
                    }
                  }

                  print(investmentsAnalyzed);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return showAlphaReturnDialog(investmentsAnalyzed: investmentsAnalyzed);
                  });

                  // We would then like to build out a modified Dialog Example
                  // with annual return of each investment, of the benchmark, and
                  // the inherent alpha return.

                  // Weighted Annual return would be computed as follows (would need % of portfolio metric on investments)
                  // (percentage_i1*i1_annual_return + percentage_i2*i2_annual_return + ... + percentage_in*in_annual_return)
                  // Where i(1->n) is a selected investment with an associated annual return and percentage of portfolio specified
                },
                style: TextButton.styleFrom(
                  primary: Colors.greenAccent,
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
  final List<String> benchmark;
  final Function() notify;
  const BenchmarkDropdown({Key? key, required this.benchmark, required this.notify}) : super(key: key);

  @override
  State<BenchmarkDropdown> createState() => _BenchmarkDropdown();
}

class _BenchmarkDropdown extends State<BenchmarkDropdown> {

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.benchmark[0],
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
      onChanged: (newValue) {
        setState(() {
          widget.benchmark[0] = newValue!;
          widget.notify();
          //Set investment benchmark job to be run against
        });
      },
      items: <String>['S&P500', 'Dow Jones', 'NASDAQ', 'Bitcoin']
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

  DateTime buyDate = stringToDateTime(buyDateStr);
  DateTime sellDate = stringToDateTime(sellDateStr);

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
class AddInvestmentDialog extends StatefulWidget {
  final List<List> investments;
  final Function() notify;
  const AddInvestmentDialog({Key? key,
    required this.investments, required this.notify,}) : super(key: key);

  @override
  _AddInvestmentDialogState createState() => _AddInvestmentDialogState();
}

class _AddInvestmentDialogState extends State<AddInvestmentDialog> {
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
                            _b.text = dateTimeToString(DateTime.now());
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
                            _s.text = dateTimeToString(DateTime.now());
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
                    t.text = dateTimeToString(val);
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

class showAlphaReturnDialog extends StatefulWidget {
  final Map investmentsAnalyzed;
  const showAlphaReturnDialog({Key? key,
    required this.investmentsAnalyzed}) : super(key: key);

  @override
  _showAlphaReturnDialogState createState() => _showAlphaReturnDialogState();
}

class _showAlphaReturnDialogState extends State<showAlphaReturnDialog> {
  double dialogFontSize = 20.0;
  List<Widget> alphaReturns = []; // Holds investments alpha return Text widgets

  @override
  Widget build(BuildContext context) { // TBD whether we pass in context as parameter
    alphaReturns = investmentReturnsList(widget.investmentsAnalyzed, context);

    return SizedBox(
      width: 50,
      height: 50,
      child: Dialog(
        elevation: 10,
        insetAnimationCurve: Curves.easeInOutCubicEmphasized,
        insetAnimationDuration: const Duration(seconds: 1),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: alphaReturns.length,
          itemBuilder: (BuildContext context, int index) {
          return
            Container(
              padding: EdgeInsets.all(12.0),
              child: alphaReturns[index],
            );
          },
          separatorBuilder: (BuildContext context, int index) { return SizedBox(height: 10); },
        )
      )
    );
  }
}

TextButton exitButton(BuildContext context, TextStyle ts) {
  return TextButton( // Add Exit button for the bottom
    child: Text("Exit", style: ts),
    onPressed: () {
      // Notify parent to update rows
      Navigator.pop(context);
    },
  );
}

class investmentReturnOutput extends StatelessWidget {
  final Map investmentsAnalyzed;
  const investmentReturnOutput({Key? key, required this.investmentsAnalyzed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

List<Widget> investmentReturnsList(Map investmentsAnalyzed, BuildContext context) {
  double dialogFontSize = 20.0;
  List<Widget> alphaReturns = []; // Refresh alphaReturns Text widgets
  // Build Title Widget
  alphaReturns.add(const Text('Your Alpha Return', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)));
  alphaReturns.add(const Divider(height: 20, thickness: 5, indent: 20, endIndent: 20, color: Colors.grey));
  // Build alpha return widgets
  for (var k in investmentsAnalyzed.keys) {
    Color returnColor = Colors.green;
    if (investmentsAnalyzed[k]['alphaReturn'] < 0) // Bold actual %, make it green for + red for -
      returnColor = Colors.red;

    alphaReturns.add(Container(  // Add return widget to alphaReturns
      color: const Color.fromARGB(20, 25, 25, 25),
      child: SizedBox(
        child: Column(
          children: [
            Text('Alpha Return of Investment $k against Benchmark ${investmentsAnalyzed[k]['benchmark']}:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: dialogFontSize, fontWeight: FontWeight.bold)),
            Text('${investmentsAnalyzed[k]['alphaReturn']}%',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: dialogFontSize+4.0,
                    fontWeight: FontWeight.bold,
                    color: returnColor,
                    decorationColor: Colors.black))
          ],
        ),
      ),
    ));
  }
  // If alphaReturns length is greater than one, add weighted alpha return derived from weighted annual returns for benchmark and investments
  // Add exit button
  alphaReturns.add(exitButton(context, TextStyle(fontSize: dialogFontSize)));
  return alphaReturns;
}