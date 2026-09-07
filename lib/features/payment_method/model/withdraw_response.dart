class WithdrawResponse {
  final bool? success;
  final int? statusCode;
  final String message;
  final dynamic data;

  WithdrawResponse({
    this.success,
    this.statusCode,
    required this.message,
    this.data,
  });

  factory WithdrawResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawResponse(
      success: json['success'],
      statusCode: json['statusCode'],
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
      'data': data,
    };
  }
}
