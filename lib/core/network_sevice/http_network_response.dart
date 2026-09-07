class HttpNetworkResponse {
  final bool isSuccess;
  final Map<String, dynamic>? responseData;
  final int statusCode;
  final String? errorMessage;

  HttpNetworkResponse({
    required this.statusCode,
    this.errorMessage,
    required this.isSuccess,
    this.responseData,
  });
}
