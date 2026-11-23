// Định dạng giá tiền Việt Nam, ví dụ: 1.800.000 ₫
String formatPrice(num price) {
  final number = price.round().toString();

  final formatted = number.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );

  return '$formatted ₫';
}

// Định dạng ngày giờ: dd/MM/yyyy HH:mm
String formatDateTime(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');

  return '${two(date.day)}/${two(date.month)}/${date.year} '
      '${two(date.hour)}:${two(date.minute)}';
}
