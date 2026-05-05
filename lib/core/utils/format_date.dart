/// for user createdAt field -> since ... text
String formatDate(DateTime date) {
  return "${_monthName(date.month)} ${date.year} ${date.year < 1900? "😎" : "" }";
}

String _monthName(int month) {
  const months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  return months[month - 1];
}