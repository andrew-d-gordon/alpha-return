// Remote Imports
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

// Local Imports
import 'package:test_project/common/string_datetime.dart';
import 'package:test_project/ui/closeout_button.dart';
import 'package:test_project/ui/ar_home.dart';

// Error messages for add investment dialog
String nullTickerError = "Investment symbol cannot be empty";
String nullDateError = "Buy and Sell dates cannot be empty";
String badCharactersError = "Ticker symbol has invalid characters";
String offsetDateError = "Buy date must occur before the Sell date";
String sameDateError = "Buy and Sell dates cannot be the same day";

// Error check +Inv investment, return error string, "" if no error
String? errorCheckInvestmentTicker(String ticker) {
  if (ticker == '') { // Null input check
    // Show alert dialog with null input message
    return nullTickerError;
  }

  if (!(RegExp(r'^[.A-Za-z^-]+$').hasMatch(ticker))) { // Valid ticker characters check
    return badCharactersError;
  }

  return null;
}

// Error checks investment date
String? errorCheckInvestmentDate(String buyDateStr, String sellDateStr) {

  if (buyDateStr == '' || sellDateStr == '') { // Null input check
    // Show alert dialog with null input message
    return nullDateError;
  }

  DateTime buyDate = stringToDateTime(buyDateStr);
  DateTime sellDate = stringToDateTime(sellDateStr);

  if (buyDate.compareTo(sellDate) > 0) { // If buyDate is after sellDate
    // Show alert dialog with invalid dates message
    return offsetDateError;
  } else if (buyDate.compareTo(sellDate) == 0) { // If buyDate==sellDate
    // Show alert dialog notifying user of same buy and sell date
    return sameDateError;
  }

  // Valid date pairing
  return null;
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
  bool _addPressed = false;

  // Text controllers and dialog font size
  final TextEditingController _t = TextEditingController();
  final TextEditingController _b = TextEditingController();
  final TextEditingController _s = TextEditingController();
  double dialogFontSize = 20.0;

  // Form key and submission clause
  final _formKey = GlobalKey<FormState>();
  void _submit() {
    // If all the text form fields are valid, add investment
    setState(() => _addPressed = true);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Valid Investment, add new row and notify
      _ticker = _t.text;
      _buyDate = _b.text;
      _sellDate = _s.text;
      widget.investments.add([
        _ticker,
        _buyDate,
        _sellDate,
        true]);

      // Notify parent to update rows
      widget.notify();

      // Pop window and clear values for next add investment
      Navigator.pop(context);
      print("New row: $_ticker $_buyDate $_sellDate");
      // Reset text in controllers
      _t.text = _b.text = _s.text = '';
      _addPressed = false;
    }
  }


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
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      TextFormField(
                                        style: TextStyle(fontSize: dialogFontSize),
                                        decoration: const InputDecoration(
                                          labelText: "Investment Symbol",
                                          hintText: "'AAPL', 'BTC-USD', 'TCS.NS'",
                                          border: OutlineInputBorder(),
                                        ),
                                        controller: _t,
                                        autovalidateMode: _addPressed
                                                          ? AutovalidateMode.onUserInteraction
                                                          : AutovalidateMode.disabled,
                                        validator: (symbol) { // Validate investment symbol
                                          return errorCheckInvestmentTicker(symbol!);
                                        },
                                      ),
                                      TextFormField(
                                          style: TextStyle(fontSize: dialogFontSize),
                                          decoration: const InputDecoration(
                                            labelText: "Buy Date",
                                            hintText: "Date as 'dd/mm/yyyy'",
                                            border: OutlineInputBorder(),
                                          ),
                                          // Shift focus to Date Picker
                                          focusNode: AlwaysDisabledFocusNode(),
                                          controller: _b,
                                          autovalidateMode: _addPressed
                                              ? AutovalidateMode.onUserInteraction
                                              : AutovalidateMode.disabled,
                                          validator: (dateStr) { // Validate buy date
                                            return errorCheckInvestmentDate(dateStr!, _s.text);
                                          },
                                          onChanged: (dateStr) => setState(() => _b.text = dateStr),
                                          onTap: () {
                                            _b.text = dateTimeToString(DateTime.now());
                                            _selectDate(context, _b);
                                          }
                                      ),
                                      TextFormField(
                                          style: TextStyle(fontSize: dialogFontSize),
                                          decoration: const InputDecoration(
                                            labelText: "Sell Date",
                                            hintText: "Date as 'dd/mm/yyyy'",
                                            border: OutlineInputBorder(),
                                          ),
                                          // Shift focus to Date Picker
                                          focusNode: AlwaysDisabledFocusNode(),
                                          controller: _s,
                                          autovalidateMode: _addPressed
                                              ? AutovalidateMode.onUserInteraction
                                              : AutovalidateMode.disabled,
                                          validator: (dateStr) { // Validate sell date
                                            return errorCheckInvestmentDate(_b.text, dateStr!);
                                          },
                                          onChanged: (dateStr) => setState(() => _s.text = dateStr),
                                          onTap: () {
                                            _s.text = dateTimeToString(DateTime.now());
                                            _selectDate(context, _s);
                                          }
                                      ),
                                      TextButton(
                                        child: Text("Add Investment", style: TextStyle(fontSize: dialogFontSize)),
                                        onPressed: _submit,
                                      ),
                                    ],
                                  ),
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

  // Cupertino date selector for buy and sell dates
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
