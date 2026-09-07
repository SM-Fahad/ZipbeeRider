  String getFirstWords(String text) {
  return text
      .trim()
      .split(RegExp(r'\s+'))
      .take(3)
      .join(' ');
}