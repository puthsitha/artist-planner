class CustomException implements Exception {
  CustomException(this.message);
  final String message; // Pass your message in constructor.

  @override
  String toString() {
    return message;
  }
}
