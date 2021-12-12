// Remote Imports
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

// Local Imports
import 'package:test_project/common/string_datetime.dart';
import 'package:test_project/common/errorcheck_investment.dart';
import 'package:test_project/ui/closeout_button.dart';
import 'package:test_project/ui/ar_home.dart';

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
      // Valid Investment, add new row and notify
      // Optional buy and sell price specified
      if ((_bp.text != '' && _sp.text != '') && (_bp.text != '0.0' && _sp.text != '0.0')) {
        widget.investments.add([
          _t.text,
          _b.text,
          _s.text,
          true, // Selected
          double.parse(_bp.text), // Optional buy price as double, add try catch last ditch effort
          double.parse(_sp.text), // Optional sell price as double
          true // Custom investment t/f (true if buy price and sell price specified)
        ]);
      } else { // Optional buy and sell price not specified
        widget.investments.add([
          _t.text,
          _b.text,
          _s.text,
          true, // Selected
          null, // Optional buy price as double
          null, // Optional sell price as double
          false // Custom investment t/f (false if buy price and sell price not specified)
        ]);
      }

      // Notify parent to update rows
      widget.notify();

      // Pop window and clear values for next add investment
      Navigator.pop(context);
      // Reset text in controllers
      _t.text = _b.text = _s.text = _bp.text = _sp.text = '';
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
                                          labelText: "Investment Symbol/Name",
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
                                                  validator: (price) { // Validate buy price (optional)
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
