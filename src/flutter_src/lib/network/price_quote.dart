//Imports
import 'dart:convert';
import 'package:http/http.dart' as http;

// Time Constants
int secondsInADay = 86400; // Used for adding secondsInADay to initial time stamp

// Request Headers
Map<String, String> corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  'Access-Control-Allow-Headers': '*',
  'Access-Control-Allow-Methods': '*',
  //'Access-Control-Allow-Credentials': 'true',
  'Accept': 'application/json',
};

// Find closing prices of a supplied investment on a specified date
Future<double> retrieveMarketValue(String ticker, DateTime date) async {
  double dateClosePrice = 0.0;
  int dateUnixStamp = date.toUtc().millisecondsSinceEpoch ~/ 1000;
  print("============================================\nTicker requested is: $ticker on date: $date\n");
  //Example url which is produced
  //https://query2.finance.yahoo.com/v8/finance/chart/AAPL?symbol=AAPL&period1=1636704000&period2=1636790400&interval=1d&events=history
  //String url = 'https://$authority/$unencodedPath/$ticker?&symbol=$ticker&period1=$dateUnixStamp&period2=${dateUnixStamp+secondsInADay}&interval=1d&events=history';

  // Reference on utilizing cors proxy
  /*String authority = 'cors-anywhere.herokuapp.com';
  String unencodedPath = 'query2.finance.yahoo.com/v8/finance/chart/$ticker';*/
  // Build URI paremeters out
  String authority = 'query2.finance.yahoo.com';
  String unencodedPath = 'v8/finance/chart/$ticker';
  var queryParemeters = {
    'symbol': ticker, // Investment Symbol e.g. 'AAPL', '^GSPC', 'BTC-USD'
    'period1': dateUnixStamp.toString(), // Start Date
    'period2': (dateUnixStamp+secondsInADay).toString(), // End Date
    'interval': '1d',
    'events': 'history'
  };

  Uri uri = Uri.https(authority, unencodedPath, queryParemeters); // Build URI
  print("This is uri: $uri");
  http.Response res = await http.get(uri, headers: corsHeaders); // Run Get Request for Investment Data
  if (res.statusCode == 200) { // If response is valid, parse body data for price
    Map<String, dynamic> body = jsonDecode(res.body);
    // Extract quote/adjclose dict with pricing info for desired date
    //Map<String, dynamic> quote = body['chart']['result'][0]['indicators']['quote'][0];
    //dateClosePrice = quote['close'][0];
    Map<String, dynamic> indicators = body['chart']['result'][0]['indicators'];
    print('This is indicators returned:\n$indicators\n\n');

    // Retrieve adjusted close price for investment
    Map<String, dynamic> adjCloseEntry = body['chart']['result'][0]['indicators']['adjclose'][0];
    dateClosePrice = adjCloseEntry['adjclose'][0];
  } else {
    print('Response was invalid with status code: ${res.statusCode}');
  }

  return dateClosePrice;
}