// Remote Imports
import 'dart:convert';
import 'package:crypto/crypto.dart';

// Use SHA1 to get hash value for individual investments
String hashInvestment(String ticker, String buyDateStr, String sellDateStr) {
  var investmentStrBytes = utf8.encode('$ticker $buyDateStr $sellDateStr');
  var digest = sha1.convert(investmentStrBytes);
  return digest.toString();
}

// Driver function for hashInvestment, splits investment appropriately
String investmentHash(List inv) {
  return hashInvestment(inv[0], inv[1], inv[2]);
}