import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Header row for investment row list
class InvestmentRowKeys extends StatefulWidget {
  final Function() notify;
  final List<List> investments;
  final List status;
  const InvestmentRowKeys({Key? key,
    required this.notify,
    required this.investments,
    required this.status}) : super(key: key);

  @override
  State<InvestmentRowKeys> createState() => _InvestmentRowKeysState();
}

class _InvestmentRowKeysState extends State<InvestmentRowKeys> {
  final double rowFontSize = 22.0;

  @override
  Widget build(BuildContext context) { // Probably convert to stateless for sel all/desel all
    return SizedBox(
      height: 40.0,
      child: Container(
        decoration: BoxDecoration(
          border: const Border(
            bottom: BorderSide(width: 2.0, color: Colors.black),
            top: BorderSide(width: 2.0, color: Colors.black),
          ),
          color: Colors.green.shade200,
        ),
        child: Row( // Convert rows to stateful objects with alterable vars
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: rowFontSize, decoration: TextDecoration.underline),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  'Buy Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: rowFontSize, decoration: TextDecoration.underline),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  'Sell Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: rowFontSize, decoration: TextDecoration.underline),
                ),
              ),
              Expanded(
                flex: 2,
                child: _masterInvestmentCheckBox(),
              ),
            ]
        ),
      ),
    );
  }

  _masterInvestmentCheckBox() { // Master sel all desel all checkbox
    return Container(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 2.0, 0.0),
      child: Checkbox(
        value: widget.status[0],
        checkColor: Colors.black,
        activeColor: Colors.greenAccent,
        //side: const BorderSide(color: Colors.blue, width: 2.0, style: BorderStyle.solid),
        onChanged: (newValue) {
          setState(() {  // Update values in list
            widget.status[0] = newValue!;
            for (int i=0; i<widget.investments.length; i++) {
              widget.investments[i][3] = newValue;
            }
            // Notify parent to take account of checkboxes
            widget.notify();
          });
        },
      ),
    );
  }
}

