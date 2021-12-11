// Error messages for add investment dialog
import 'package:test_project/common/string_datetime.dart';
import 'package:test_project/common/is_numeric.dart';

String nullTickerError = "Investment symbol cannot be empty";
String nullDateError = "Buy and Sell dates cannot be empty";
String badCharactersError = "Ticker symbol has invalid characters";
String offsetDateError = "Buy date must occur before the Sell date";
String sameDateError = "Buy and Sell dates cannot be the same day";
String onePriceOnlyError = "Need both prices";
String nonNumericBuySellPrice = "Buy and Sell price must be numeric";

// Error check +Inv investment, return error string, "" if no error
String? errorCheckInvestmentTicker(String ticker) {
  if (ticker == '') { // Null input check
    // Show alert dialog with null input message
    return nullTickerError;
  }

  if (!(RegExp(r'^[.A-Za-z^-]+$').hasMatch(ticker))) { // Valid ticker characters check
    return badCharactersError;
  }

  return null;
}

// Error checks investment date
String? errorCheckInvestmentDate(String buyDateStr, String sellDateStr) {

  if (buyDateStr == '' || sellDateStr == '') { // Null input check
    // Show alert dialog with null input message
    return nullDateError;
  }

  DateTime buyDate = stringToDateTime(buyDateStr);
  DateTime sellDate = stringToDateTime(sellDateStr);

  if (buyDate.compareTo(sellDate) > 0) { // If buyDate is after sellDate
    // Show alert dialog with invalid dates message
    return offsetDateError;
  } else if (buyDate.compareTo(sellDate) == 0) { // If buyDate==sellDate
    // Show alert dialog notifying user of same buy and sell date
    return sameDateError;
  }

  // Valid date pairing
  return null;
}

String? errorCheckBuySellPrice(String buyPrice, String sellPrice) {
  // As Buy and Sell price attributes optional, if both empty return null (okay)
  if (buyPrice == '' && sellPrice == '') {
    return null;
  }

  // If one price specified without the other
  if ((buyPrice == '' && sellPrice != '') || (buyPrice != '' && sellPrice == '')) {
    return onePriceOnlyError;
  } else if (!isNumeric(buyPrice) || !isNumeric(sellPrice)) {
    return nonNumericBuySellPrice;
  }

  return null;
}
