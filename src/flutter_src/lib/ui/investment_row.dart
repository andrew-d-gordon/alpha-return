// Remote Imports
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Formats string date of form 'mm/dd/yyyy' to DateTime
DateTime stringToDateTime(String dateStr) {
  List dateSplit = dateStr.split('/');
  return DateTime(int.parse(dateSplit[2]), int.parse(dateSplit[0]), int.parse(dateSplit[1]));
}

// Formats DateTime date to 'mm/dd/yyyy'
String dateTimeToString(DateTime date) {
  return "${date.month.toString()}/${date.day.toString()}/${date.year.toString()}";
}

BoxDecoration investmentBoxDecoration(Color c, Color borderC) { // Box Decoration Widget
  return BoxDecoration(
    border: Border.all(
      color: borderC,
      width: 1,
    ),
    color: c,
  );
}

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
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(0.0),
              decoration: investmentBoxDecoration(Colors.lightGreen, Colors.black),
              child: Text(
                widget.symbol,
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
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
                overflow: TextOverflow.ellipsis,
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: InvestmentCheckBox(notify: widget.notify,
            investments: widget.investments,
            row: widget.row,),
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
        contentPadding: const EdgeInsets.all(0.0),
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

  if (!(RegExp(r'^[.A-Za-z^-]+$').hasMatch(ticker))) { // Valid ticker characters check
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
                        child: Stack(
                          children: <Widget>[
                            Column(
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
                            ),
                            dialogCloseOutButton(context),
                          ]
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
          ]
        )
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
            child: Stack(
              children: <Widget>[
                ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: alphaReturns.length,
                  itemBuilder: (BuildContext context, int index) {
                    return
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        child: alphaReturns[index],
                      );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 10);
                  },
                ),
                dialogCloseOutButton(context),
              ]
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
            Text('Alpha Return of Investment ${investmentsAnalyzed[k]['ticker']} against Benchmark ${investmentsAnalyzed[k]['benchmark']}:',
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

// Closeout button for dialogs windows
Widget dialogCloseOutButton(BuildContext context) {
  return Positioned( // Closeout button
    right: 0.0,
    child: GestureDetector(
      onTap: (){
        Navigator.of(context).pop();
      },
      child: const Align(
        alignment: Alignment.topRight,
        child: CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.white30,
          child: Icon(Icons.close, color: Colors.lightGreen, size: 25.0,),
        ),
      ),
    ),
  );
}

