const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String twoDigits(int n) => n.toString().padLeft(2, '0');

String formatHm(int hour, int minute) =>
    '${twoDigits(hour)}:${twoDigits(minute)}';

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatDateTime(DateTime d) =>
    '${d.day} ${_months[d.month - 1]}, ${formatHm(d.hour, d.minute)}';

String formatDuration(Duration d) {
  if (d.inDays >= 1) return '${d.inDays} d ${d.inHours % 24} h';
  if (d.inHours >= 1) {
    return '${d.inHours} h ${twoDigits(d.inMinutes % 60)} min';
  }
  if (d.inMinutes >= 1) return '${d.inMinutes} min';
  return 'under a minute';
}
