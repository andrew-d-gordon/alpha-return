// Remote Imports
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

// Local Imports
import 'package:test_project/ui/investment_row.dart';
import 'package:test_project/ui/add_investment.dart';
import 'package:test_project/ui/addrows_notice.dart';
import 'package:test_project/ui/investmentrow_keys.dart';
import 'package:test_project/common/string_datetime.dart';
import 'package:test_project/common/days_between.dart';
import 'package:test_project/common/hash_investment.dart';
import 'package:test_project/common/fin_analysis.dart';
import 'package:test_project/network/price_quote.dart';


// Set theme background
bool lightTheme = false;
Color lightThemeBackground = Colors.white;
Color darkThemeBackground = const Color(0xFF363636);
Color appBackgroundColor = lightTheme ? lightThemeBackground:darkThemeBackground;

class ARHome extends StatefulWidget {
  const ARHome({Key? key}) : super(key: key);

  @override
  State<ARHome> createState() => _ARHomeState();
}

class _ARHomeState extends State<ARHome> {

  // Refresh Callback for descendant widgets to notify parent of updated values
  refresh() {setState(() {});}

  // Variable data utilized to generate investment rows and their state variables
  // Investments has an investment specified as:
  // [Symbol, BuyDate, SellDate, Selected (t/f), Buy Price (double?), Sell Price (double?), Manual (t/f)]
  List<List> investments = [
    ['AAPL', '01/04/2021', '11/12/2021', true, null, null, false],
    ['RELIANCE.NS', '12/01/2021', '12/05/2021', true, null, null, false], // Non-US Market '_._' test
    ['VTI', '12/04/2021', '12/05/2021', true, null, null, false], // Weekend days test, should be 0.0%
    ['AAPL', '01/06/2021', '11/15/2021', true, null, null, false], // Duplicate ticker investment test
    ['BTC-USD', '12/04/2021', '12/05/2021', true, null, null, false], // Bitcoin on weekend pricing test
    ['AMZN', '01/04/2021', '11/12/2021', false, null, null, false],
    ['VTI', '01/04/2021', '11/12/2021', false, null, null, false],
    ['BTC-USD', '01/04/2021', '11/12/2021', false, null, null, false],
    ['AMZN', '01/06/2021', '11/15/2021', false, null, null, false],
    ];

  // Holds investmentRows built from investments
  List<Widget> investmentRows = [];
  List masterCheckBoxStatus = [false];

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
    if (investments.isEmpty) {
      investmentRows.add(const AddRowsNotice());
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
    if (investments.isEmpty) { // If no investments added, place notice
      investmentRows.add(const AddRowsNotice());
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
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 2.0, color: lightTheme ? darkThemeBackground:lightThemeBackground),
                  )
                ),
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                //color: Colors.cyan,
                child: Stack(
                  children: <Widget>[
                    ListView(
                      padding: const EdgeInsets.fromLTRB(0.0, 40.0, 1.0, 1.0),
                      children: <Widget>[ // Where Investments live...
                        for (var r in investmentRows) r,
                      ],
                      scrollDirection: Axis.vertical,
                    ),
                    Positioned(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: InvestmentRowKeys(investments: investments,
                                                notify: refresh,
                                                status: masterCheckBoxStatus),
                      ),
                    ),
                  ]
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
                        child: DeleteInvestmentsButton(investments: investments, masterCheckStatus: masterCheckBoxStatus, notify: refresh),
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
                  // Holds analyzed investments
                  Map investmentsAnalyzed = {};
                  // Benchmark ticker to retrieve benchmark prices from api
                  String benchmarkTicker = benchmarks[benchmark[0]]!;
                  // Used to determine computation of weightedAlphaReturn
                  int investmentCount = 0;

                  // Iterate through investments, compute alpha return for selected investments
                  for (int i=0; i<investments.length; i++) {
                    // Increment number of investments analyzed
                    investmentCount += 1;
                    // If investment selected (investments[i][3] == true), compute annual return
                    if (investments[i][3]) {
                      // Retrieve investment data and initialize analysis attributes
                      List inv = investments[i];
                      String key = investmentHash(inv);
                      investmentsAnalyzed[key] = {};
                      DateTime buyDate = stringToDateTime(inv[1]);
                      DateTime sellDate = stringToDateTime(inv[2]);

                      if (inv[6]) { // Investment has specified buy and sell price
                        investmentsAnalyzed[key]['buyPrice'] = inv[4];
                        investmentsAnalyzed[key]['sellPrice'] = inv[5];
                      } else { // Investment does not have specified buy and sell price
                        // Add error checks, continue on error, remove error prone rows/notify user
                        await retrieveMarketValue(inv[0], buyDate).then((val) => {
                          investmentsAnalyzed[key]['buyPrice'] = val
                        });
                        await retrieveMarketValue(inv[0], sellDate).then((val) => {
                          investmentsAnalyzed[key]['sellPrice'] = val
                        });
                      }

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
                      investmentsAnalyzed[key]['annualReturn'] = computeAnnualReturn( // Annual Return
                          investmentsAnalyzed[key]['buyPrice'],
                          investmentsAnalyzed[key]['sellPrice'],
                          daysDiff);
                      investmentsAnalyzed[key]['totalGain'] = totalGain( // Total % Gain
                        investmentsAnalyzed[key]['buyPrice'],
                        investmentsAnalyzed[key]['sellPrice']);

                      investmentsAnalyzed[key]['benchmark'] = benchmark[0];
                      investmentsAnalyzed[key]['benchmarkAnnualReturn'] = computeAnnualReturn( // Annual Return
                          investmentsAnalyzed[key]['benchBuyPrice'],
                          investmentsAnalyzed[key]['benchSellPrice'],
                          daysDiff);
                      investmentsAnalyzed[key]['benchmarkTotalGain'] = totalGain( // Total % Gain
                        investmentsAnalyzed[key]['benchBuyPrice'],
                        investmentsAnalyzed[key]['benchSellPrice'],
                      );

                      investmentsAnalyzed[key]['alphaReturn'] = computeAlphaReturn(
                          investmentsAnalyzed[key]['annualReturn'],
                          investmentsAnalyzed[key]['benchmarkAnnualReturn']
                      );
                    }
                  }

                  if (investmentCount == 0) { // No investments analyzed, show alert to user
                    print('No investments selected to analyze.');
                  } else { // Investments were analyzed, show alpha return
                    if (investmentsAnalyzed.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return showAlphaReturnDialog(
                            investmentsAnalyzed: investmentsAnalyzed,
                            benchmark: benchmark[0],);
                        });
                    }
                  }

                  // We would then like to build out a modified Dialog Example
                  // with annual return of each investment, of the benchmark, and
                  // the inherent alpha return.

                  // Weighted annual return would be computed as follows (would need % of portfolio metric on investments)
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
    backgroundColor: appBackgroundColor,
    );
  }
}