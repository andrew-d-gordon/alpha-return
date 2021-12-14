// Remote Imports
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_project/ui/closeout_button.dart';
import 'package:test_project/ui/edit_investment.dart';
import 'package:test_project/common/fin_analysis.dart';

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
  final String benchmark;
  const showAlphaReturnDialog({Key? key,
    required this.investmentsAnalyzed, required this.benchmark}) : super(key: key);

  @override
  _showAlphaReturnDialogState createState() => _showAlphaReturnDialogState();
}

class _showAlphaReturnDialogState extends State<showAlphaReturnDialog> {
  double dialogFontSize = 20.0;
  List<Widget> alphaReturns = []; // Holds investments alpha return Text widgets

  @override
  Widget build(BuildContext context) { // TBD whether we pass in context as parameter
    double? weightedAvgAR; // Use to hold weighted average alpha return
    // If we have more than one investment analyzed, set flag to show weighted alpha return
    bool showWeightedAlphaReturn = (widget.investmentsAnalyzed.keys.length>1)?true:false;
    if (showWeightedAlphaReturn) { // More than one investment selected, show weighted alpha return
      List<List<double>> returnsAndVolumes = []; // Holds alpha return and percentage makeup of portfolio for each investment
      double defaultVolume = 1/widget.investmentsAnalyzed.keys.length; // 1/(num investments analyzed) equates investments in percentage makeup for portfolio
      for (var i in widget.investmentsAnalyzed.keys) { // Find alpha return and volume of each investment
        returnsAndVolumes.add([widget.investmentsAnalyzed[i]['alphaReturn'], defaultVolume]);
      }
      weightedAvgAR = computeWeightedAlphaReturn(returnsAndVolumes);
      print("This is weighted average alpha return: $weightedAvgAR");
      // Add display widget to alphaReturnsList if successful
    }

    alphaReturns = investmentReturnsList(widget.investmentsAnalyzed, widget.benchmark, weightedAvgAR, context);

    return SizedBox(
        width: 50,
        height: 50,
        child: Dialog(
            elevation: 10,
            insetAnimationCurve: Curves.easeInOutCubicEmphasized,
            insetAnimationDuration: const Duration(seconds: 1),
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
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
              ),
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

// Use to return output list boxes showing AR for investments and weighted average return (if >1 investment)
List<Widget> investmentReturnsList(Map investmentsAnalyzed, String benchmark, double? weightedAvgAR, BuildContext context) {
  double dialogFontSize = 20.0;
  List<Widget> alphaReturns = []; // Refresh alphaReturns Text widgets

  // Build Title Widget
  alphaReturns.add(const Text('Your Returns', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)));
  alphaReturns.add(const Divider(height: 20, thickness: 5, indent: 20, endIndent: 20, color: Colors.grey));

  // Build alpha return widgets
  for (var k in investmentsAnalyzed.keys) {
    Color returnColor = Colors.green;
    if (investmentsAnalyzed[k]['alphaReturn'] < 0) {
      returnColor = Colors.red;
    }

    alphaReturns.add(Container(  // Add return widget to alphaReturns
      color: const Color.fromARGB(20, 25, 25, 25),
      child: SizedBox(
        child: Column(
          children: [
            Text('Return of Investment ${investmentsAnalyzed[k]['ticker']} against Benchmark $benchmark:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: dialogFontSize, fontWeight: FontWeight.bold)),
            investmentReturnTable(
                investmentsAnalyzed[k]['ticker'],
                benchmark,
                investmentsAnalyzed[k]['totalGain'],
                investmentsAnalyzed[k]['benchmarkTotalGain'],
                investmentsAnalyzed[k]['annualReturn'],
                investmentsAnalyzed[k]['benchmarkAnnualReturn']),
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

  // If weighted avg return available, add widget display to output
  if (weightedAvgAR!=null) {
    Color returnColor = Colors.green;
    if (weightedAvgAR < 0) { // If negative weightedAvgAR, return color red
      returnColor = Colors.red;
    }

    alphaReturns.add(Container(
      color: const Color.fromARGB(20, 25, 25, 25),
      child: SizedBox(
        child: Column(
          children: [
            Text('Weighted Average Alpha Return of Investments against Benchmark $benchmark:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: dialogFontSize, fontWeight: FontWeight.bold)),
            Text('$weightedAvgAR%',
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
  // Add exit button
  alphaReturns.add(exitButton(context, TextStyle(fontSize: dialogFontSize)));
  return alphaReturns;
}

// Returns table for alpha return dialog with investment
Table investmentReturnTable(String investmentSymbol,
                            String benchmark,
                            double investmentGain,
                            double benchmarkGain,
                            double investmentCompound,
                            double benchmarkCompound) {
  BoxDecoration tableBackgroundColor = const BoxDecoration(
    color: Color.fromARGB(20, 25, 25, 25),);

  return Table(
    border: TableBorder.all(),
    columnWidths: const <int, TableColumnWidth>{
      0: FlexColumnWidth(),
      1: FlexColumnWidth(),
      2: FlexColumnWidth(),
      //3: FixedColumnWidth(64),
    },
    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    children: <TableRow>[
      TableRow( // Header Row: Returns | Investment | Benchmark
        children: <Widget>[
          const Text(''),
          Center(child: Text(investmentSymbol)),
          Center(child: Text(benchmark)),
        ],
      ),
      TableRow( // Total % Gain Row: Total Gain | investmentGain% | benchmarkGain%
        decoration: tableBackgroundColor,
        children: <Widget>[
          const Center(child: Text('Total Gain')),
          Center(child: Text('$investmentGain%')),
          Center(
            child: Text('$benchmarkGain%')
          ),
        ],
      ),
      TableRow( // Annual Return % Row: Annual Return | investmentCompound% | benchmarkCompound%
        decoration: tableBackgroundColor,
        children: <Widget>[
          const Center(child: Text('Annual Return')),
          Center(child: Text('$investmentCompound%')),
          Center(child: Text('$benchmarkCompound%')),
        ]
      )
    ],
  );
}
