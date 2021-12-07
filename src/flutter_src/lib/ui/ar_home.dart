// Remote Imports
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

// Local Imports
import 'investment_row.dart';
import '../network/price_quote.dart';
import '../common/fin_analysis.dart';
import '../common/hash_investment.dart';

// Formats string date of form 'mm/dd/yyyy' to DateTime
DateTime stringToDateTime(String dateStr) {
  List dateSplit = dateStr.split('/');
  return DateTime(int.parse(dateSplit[2]), int.parse(dateSplit[0]), int.parse(dateSplit[1]));
}

// Formats DateTime date to 'mm/dd/yyyy'
String dateTimeToString(DateTime date) {
  return "${date.month.toString()}/${date.day.toString()}/${date.year.toString()}";
}

// Compute days between two dates
int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

class ARHome extends StatefulWidget {
  const ARHome({Key? key}) : super(key: key);

  @override
  State<ARHome> createState() => _ARHomeState();
}

class _ARHomeState extends State<ARHome> {

  // Refresh Callback for descendant widgets to notify parent of updated values
  refresh() {setState(() {});}

  // Variable data utilized to generate investment rows and their state variables
  // investments has an investment specified as: [Symbol, BuyDate, SellDate, Selected (t/f)]
  List<List> investments = [
    ['AAPL', '01/04/2021', '11/12/2021', false],
    ['AMZN', '01/04/2021', '11/12/2021', false],
    ['VTI', '01/04/2021', '11/12/2021', false],
    ['BTC-USD', '01/04/2021', '11/12/2021', false],
    ['AAPL', '01/06/2021', '11/15/2021', false],
    ['AMZN', '01/06/2021', '11/15/2021', false],
    ['VTI', '12/04/2021', '12/05/2021', true], // Weekend days test
    ['BTC-USD', '12/04/2021', '12/05/2021', true]]; // Weekend days test

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
  void initState() { // Fill investments row space with recalled investments
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
                      // Retrieve investment data and initialize analysis attributes
                      List inv = investments[i];
                      String key = investmentHash(inv);
                      investmentsAnalyzed[key] = {};
                      DateTime buyDate = stringToDateTime(inv[1]);
                      DateTime sellDate = stringToDateTime(inv[2]);

                      // Get buy and sell closing prices
                      await retrieveMarketValue(inv[0], buyDate).then((val) => { // Add error checks, continue on error, remove error prone rows/notify user
                        investmentsAnalyzed[key]['buyPrice'] = val
                      });
                      await retrieveMarketValue(inv[0], sellDate).then((val) => {
                        investmentsAnalyzed[key]['sellPrice'] = val
                      });
                      await retrieveMarketValue(benchmarkTicker, buyDate).then((val) => {
                        investmentsAnalyzed[key]['benchBuyPrice'] = val
                      });
                      await retrieveMarketValue(benchmarkTicker, sellDate).then((val) => {
                        investmentsAnalyzed[key]['benchSellPrice'] = val
                      });
                      int daysDiff = daysBetween(stringToDateTime(inv[1]), stringToDateTime(inv[2]));

                      // Set Investment Analysis attributes in investmentsAnalyzed
                      investmentsAnalyzed[key]['ticker'] = inv[0];
                      investmentsAnalyzed[key]['daysDiff'] = daysDiff;
                      investmentsAnalyzed[key]['annualReturn'] = computeAnnualReturn(
                          investmentsAnalyzed[key]['buyPrice'],
                          investmentsAnalyzed[key]['sellPrice'],
                          daysDiff);

                      investmentsAnalyzed[key]['benchmark'] = benchmark[0]; // Make non null
                      investmentsAnalyzed[key]['benchmarkAnnualReturn'] = computeAnnualReturn(
                          investmentsAnalyzed[key]['benchBuyPrice'],
                          investmentsAnalyzed[key]['benchSellPrice'],
                          daysDiff);

                      investmentsAnalyzed[key]['alphaReturn'] = computeAlphaReturn(
                          investmentsAnalyzed[key]['annualReturn'],
                          investmentsAnalyzed[key]['benchmarkAnnualReturn']
                      );
                    }
                  }

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