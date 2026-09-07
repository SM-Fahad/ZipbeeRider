class StripeAccountResponse {
  final bool success;
  final String message;
  final AccountLinkData data;

  StripeAccountResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StripeAccountResponse.fromJson(Map<String, dynamic> json) {
    return StripeAccountResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: AccountLinkData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class AccountLinkData {
  final String object;
  final int created;
  final int expiresAt;
  final String url;

  AccountLinkData({
    required this.object,
    required this.created,
    required this.expiresAt,
    required this.url,
  });

  factory AccountLinkData.fromJson(Map<String, dynamic> json) {
    return AccountLinkData(
      object: json['object'] ?? '',
      created: json['created'] ?? 0,
      expiresAt: json['expires_at'] ?? 0,
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'object': object,
      'created': created,
      'expires_at': expiresAt,
      'url': url,
    };
  }
}
