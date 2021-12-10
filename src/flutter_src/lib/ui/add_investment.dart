import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:test_project/common/string_datetime.dart';
import 'package:test_project/ui/closeout_button.dart';
import 'package:test_project/ui/ar_home.dart';

// Error check +Inv investment, return error string, "" if no error
String? errorCheckInvestment(String ticker, String buyDateStr, String sellDateStr) {
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
    return null;
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
  // Investment Attributes
  String _ticker = "";
  String _buyDate = "";
  String _sellDate = "";

  // TextField Error Message Placeholders
  String? _tError;
  String? _bError;
  String? _sError;

  // Text controllers and dialog font size
  final TextEditingController _t = TextEditingController();
  final TextEditingController _b = TextEditingController();
  final TextEditingController _s = TextEditingController();
  double dialogFontSize = 20.0;

  // Refresh Callback for error messages
  refresh() {setState(() {});}
  @override
  void dispose() { // Dispose of controllers when unmounted
    _t.dispose();
    _b.dispose();
    _s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appBackgroundColor,
        body: Column(
            children: <Widget>[
              FloatingActionButton(onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      width: 100,
                      height: 50,
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
                                      decoration: InputDecoration(
                                        labelText: "Investment Symbol",
                                        hintText: "'AAPL', 'BTC-USD', 'TCS.NS'",
                                        errorText: _tError,
                                        border: const OutlineInputBorder(),
                                      ),
                                      controller: _t,
                                    ),
                                    TextField(
                                        style: TextStyle(fontSize: dialogFontSize),
                                        decoration: InputDecoration(
                                          labelText: "Buy Date",
                                          hintText: "Date as 'dd/mm/yyyy'",
                                          errorText: _bError,
                                          border: const OutlineInputBorder(),
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
                                        decoration: InputDecoration(
                                          labelText: "Sell Date",
                                          hintText: "Date as 'dd/mm/yyyy'",
                                          errorText: _sError,
                                          border: const OutlineInputBorder(),
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
                                        String? error;
                                        setState(() {
                                          // Error check investment
                                          error = errorCheckInvestment(_t.text, _b.text, _s.text);
                                          if (error != null) {
                                            validInvestment = false;
                                            _tError = _bError = _sError = error;
                                            refresh();
                                            return;
                                          }

                                          _ticker = _t.text;
                                          _buyDate = _b.text;
                                          _sellDate = _s.text;

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
                                          _tError = _bError = _sError = null;
                                          refresh();
                                        } else {
                                          // Display error message
                                          print(error);
                                          _tError = _bError = _sError = error;
                                          refresh();
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

  //errorText for text controllers
  String? get _errorText {
    // Error check investment
    return errorCheckInvestment(_t.text, _b.text, _s.text);
  }

  // Cupertino date selector
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
