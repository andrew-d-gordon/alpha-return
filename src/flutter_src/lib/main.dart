// Remote Imports
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

// Local Imports
import 'ui/ar_home.dart';

// To do:
// Associate hash ids with rows to allow for better recall in local memory dict
// Figure out how to interpolate binance/coincap market values like with yahoo
// Unrequire dependency for fin_quote

// Add buy and sell price as entry for investments, update logic in ar_home when processing investments
// to not go out and find buy and sell price for investment when it is specified.

// Investment input section/make modal area smaller
// clear inv to be added/del'd when close out pressed

// Flutter integration with firebase to store user info/market data into firestore

// Remember investment sets (security investments by hashid)

// Add characteristic line premium alpha return output, custom benchmark besides sp500 and bitcoin
// Once enough days filled in for investment compute beta and error to find expected returns on investment
// For time being can do benchmark versus investment line curves on small graph in output

// Color scheme modifier

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false, // Removes Debug Banner
  theme: ThemeData(fontFamily: 'Poppins'),
  home: ARHome(),
));