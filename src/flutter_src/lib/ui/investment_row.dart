// Remote Imports
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_project/ui/closeout_button.dart';
import 'package:test_project/ui/edit_investment.dart';

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
                fontWeight: FontWeight.w400,
                //letterSpacing: 2,
                color: Colors.white,
                backgroundColor: Colors.green,
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
    return GestureDetector(
      onTap: (){ // If row is tapped, flip check status in investment, refresh
        setState(() {
          bool status = widget.investments[widget.row][3];
          widget.investments[widget.row][3] = !status;
          widget.notify();
        });
      },
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) { return EditInvestmentDialog(row: widget.row, notify: widget.notify, investments: widget.investments); });
      },
      child: Row( // Convert rows to stateful objects with alterable vars
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
      )
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
      child: Checkbox(
        value: widget.investments[widget.row][3],
        checkColor: Colors.black,
        side: const BorderSide(color: Colors.grey, width: 2.0, style: BorderStyle.solid),
        activeColor: Colors.greenAccent,
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

// Delete Investments Button Widget
class DeleteInvestmentsButton extends StatefulWidget {
  final List<List> investments;
  final List masterCheckStatus;
  final Function() notify;
  const DeleteInvestmentsButton({Key? key,
    required this.investments,
    required this.masterCheckStatus,
    required this.notify,}) : super(key: key);

  @override
  _DeleteInvestmentsButtonState createState() => _DeleteInvestmentsButtonState();
}

class _DeleteInvestmentsButtonState extends State<DeleteInvestmentsButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(onPressed: () {
      setState(() {
        widget.investments.removeWhere((row) => row[3] == true); // Remove selected rows
        widget.masterCheckStatus[0] = false; // Ensure master select set to false
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
