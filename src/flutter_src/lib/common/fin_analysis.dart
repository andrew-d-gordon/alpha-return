// Remote Imports
import 'dart:math';

// Local Imports

// Time constants
int secondsInADay = 86400; // Used for adding secondsInADay to initial time stamp
double daysInAYear = 365.25;  // Used for computing annual return

// Round value to have specified number of places
double round(double val, int places) {
  num mod = pow(10.0, places);
  return ((val * mod).round().toDouble() / mod);
}

// Compute annual return for investment by it's buyPrice, sellPrice and date differential
double computeAnnualReturn(double buyPrice, double sellPrice, int daysDiff) {
  // Set up compound interest 'magic', daily compound interest
  num dailyCompoundInterest = pow((sellPrice/buyPrice), 1/daysDiff);

  // Compute annual return
  double annualReturn = round((dailyCompoundInterest-1)*(daysInAYear*1000000), 0);
  annualReturn /= 10000;

  return annualReturn;
}

// Computing Alpha Return for investment against benchmark
double computeAlphaReturn(double investmentReturn, double benchmarkReturn) {
  return round(investmentReturn-benchmarkReturn, 4);
}