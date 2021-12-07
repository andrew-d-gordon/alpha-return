// Remote Imports
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:fin_quote/fin_quote.dart';

// Local Imports
import 'ui/ar_home.dart';

// To do:

// Associate hash ids with rows to allow for better recall in local memory dict
// Add error message in AddInvestmentDialog to specify why investment is invalid
// Figure out how to interpolate binance/coincap market values like with yahoo
// Unrequire dependency for fin_quote

// Add more general investment addition (one where you input buy and sell prices along with arbitrary name for investment).
// Include

// Make a dialog example clone but for editing fields of a row (must know row id) ?

// Investment input section/make modal area smaller
// clear inv to be added/del'd when close out pressed

// Dart with firebase, see if python backend possible for computing alpha return

// If python not viable as backend, see if dart has built in api calls available for market data

// Flutter integration with firebase to store user info/market data into firestore

// Remember investment sets

// Color scheme modifier

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false, // Removes Debug Banner
  theme: ThemeData(fontFamily: 'ReadexPro'),
  home: ARHome(),
));