String formatDateTime(DateTime dateTime) {
  final russianMonths = [
    '',
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря'
  ];

  final day = dateTime.day.toString();
  final month = russianMonths[dateTime.month];
  final year = dateTime.year.toString();

  return '$day $month $year';
}

int hexStringToHexInt(String hex) {
  hex = hex.replaceFirst('#', '');
  hex = hex.length == 6 ? 'ff$hex' : hex;
  int val = int.parse(hex, radix: 16);
  return val;
}
