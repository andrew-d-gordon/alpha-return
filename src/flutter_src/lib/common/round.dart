// Remote Imports
import 'dart:math';

// Round value to have specified number of places
double round(double val, int places) {
  num mod = pow(10.0, places);
  return ((val * mod).round().toDouble() / mod);
}