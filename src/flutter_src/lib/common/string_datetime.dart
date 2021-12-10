// Formats string date of form 'mm/dd/yyyy' to DateTime
DateTime stringToDateTime(String dateStr) {
  List dateSplit = dateStr.split('/');
  return DateTime(int.parse(dateSplit[2]), int.parse(dateSplit[0]), int.parse(dateSplit[1]));
}

// Formats DateTime date to 'mm/dd/yyyy'
String dateTimeToString(DateTime date) {
  return "${date.month.toString()}/${date.day.toString()}/${date.year.toString()}";
}