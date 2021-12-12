// Remote Imports
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

// Local Imports
import 'package:test_project/common/string_datetime.dart';
import 'package:test_project/common/errorcheck_investment.dart';
import 'package:test_project/common/is_numeric.dart';
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
class EditInvestmentDialog extends StatefulWidget {
  final List<List> investments;
  final int row;
  final Function() notify;
  const EditInvestmentDialog({Key? key,
    required this.investments, required this.notify, required this.row,}) : super(key: key);

  @override
  _EditInvestmentDialogState createState() => _EditInvestmentDialogState();
}

class _EditInvestmentDialogState extends State<EditInvestmentDialog> {
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
  final TextEditingController _bp = TextEditingController();
  final TextEditingController _sp = TextEditingController();
  double dialogFontSize = 20.0;

  // Form key and submission clause
  final _formKey = GlobalKey<FormState>();
  void _submit() {
    // If all the text form fields are valid, add investment
    setState(() => _addPressed = true);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Optional buy and sell price specified
      if ((_bp.text != '' && _sp.text != '') && (_bp.text != '0.0' && _sp.text != '0.0')) {
        widget.investments[widget.row] = [
          _t.text,
          _b.text,
          _s.text,
          widget.investments[widget.row][3], // Selected
          double.parse(_bp.text), // Optional buy price as double, add try catch last ditch effort
          double.parse(_sp.text), // Optional sell price as double
          true // Custom investment t/f (true if buy price and sell price specified)
        ];
      } else { // Optional buy and sell price not specified
        widget.investments[widget.row] = [
          _t.text,
          _b.text,
          _s.text,
          widget.investments[widget.row][3], // Selected
          null, // Optional buy price as double
          null, // Optional sell price as double
          false // Custom investment t/f (false if buy price and sell price not specified)
        ];
      }
      // Notify parent to update rows
      widget.notify();

      // Pop window and clear values for next add investment
      Navigator.pop(context);
      // print("Edited row ${widget.row} with: $_ticker $_buyDate $_sellDate");
      // Reset text in controllers
      _t.text = _b.text = _s.text = _sp.text = _bp.text = '';
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
  void initState() { // Set current values of investment
    _t.text = widget.investments[widget.row][0];
    _b.text = widget.investments[widget.row][1];
    _s.text = widget.investments[widget.row][2];
    print("These are buy and sell prices normally: ${widget.investments[widget.row][4]} and ${widget.investments[widget.row][5]}");
    _bp.text = (widget.investments[widget.row][4]??'').toString(); // Null check converts to '' if bp is null
    _sp.text = (widget.investments[widget.row][5]??'').toString(); // Null check converts to '' if sp is null
  }

  @override
  Widget build(BuildContext context) {
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
                          hintText: "AAPL, BTC-USD, TCS.NS",
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
                      Column( // Optional buy and sell price inputs
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  style: TextStyle(fontSize: dialogFontSize),
                                  decoration: const InputDecoration(
                                    labelText: "Buy Price",
                                    //hintText: "",
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: _bp,
                                  keyboardType: TextInputType.number,
                                  autovalidateMode: _addPressed
                                      ? AutovalidateMode.onUserInteraction
                                      : AutovalidateMode.disabled,
                                  validator: (price) { // Validate investment symbol
                                    return errorCheckBuySellPrice(_bp.text, _sp.text);
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  style: TextStyle(fontSize: dialogFontSize),
                                  decoration: const InputDecoration(
                                    labelText: "Sell Price",
                                    //hintText: "",
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: _sp,
                                  keyboardType: TextInputType.number,
                                  autovalidateMode: _addPressed
                                      ? AutovalidateMode.onUserInteraction
                                      : AutovalidateMode.disabled,
                                  validator: (price) { // Validate investment symbol
                                    return errorCheckBuySellPrice(_bp.text, _sp.text);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Text('Optional use for non-stock investments'),
                        ],
                      ),
                      TextButton(
                        child: Text("Update Investment", style: TextStyle(fontSize: dialogFontSize)),
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
