const _indonesianMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String formatDate(DateTime date) {
  final month = _indonesianMonths[date.month - 1];
  return '${date.day} $month ${date.year}';
}

String formatDateRange(DateTime start, DateTime end) {
  final startDate = dateOnly(start);
  final endDate = dateOnly(end);
  if (startDate == endDate) {
    return formatDate(startDate);
  }
  return '${formatDate(startDate)} - ${formatDate(endDate)}';
}
