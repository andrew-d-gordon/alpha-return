// Remote Imports
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

// Local Imports
import 'ui/ar_home.dart';

// To do:
// Investment input section/make modal area smaller
// clear inv to be added/del'd when close out pressed

// Add 2x2 table with benchmark and investment, total gain loss %, annual ret %, below show alpha return
// Add weighted annual return benchmark for whole portfolio tile when more than one investment selected

// Flutter integration with firebase to store user info/market data into firestore

// Remember investment sets (security investments by hashid)

// Add characteristic line premium alpha return output, custom benchmark besides sp500 and bitcoin
// Add global market indices as benchmarks, remove $ from buy sell hint
// Once enough days filled in for investment compute beta and error to find expected returns on investment
// For time being can do benchmark versus investment line curves on small graph in output

// Color scheme modifier

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false, // Removes Debug Banner
  theme: ThemeData(fontFamily: 'Poppins'),
  home: ARHome(),
));