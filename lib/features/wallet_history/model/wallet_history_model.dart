class WalletHistory {
  final int id;
  final String transactionId;
  final String transactionType;
  final String type;
  final String amount;
  final String status;
  final DateTime createdAt;
  final String message;

  WalletHistory({
    required this.id,
    required this.transactionId,
    required this.transactionType,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.message,
  });

  factory WalletHistory.fromJson(Map<String, dynamic> json) {
    return WalletHistory(
      id: json['id'],
      transactionId: json['transactionId'],
      transactionType: json['transactionType'],
      type: json['type'],
      amount: json['amount'].toString(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      message: json['message'] ?? '',
    );
  }
}