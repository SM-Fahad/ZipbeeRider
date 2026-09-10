class WalletHistory {
  final int id;
  final String transactionId;
  final String transactionType;
  final String type;
  final String amount;
  final String status;
  final String currency;
  final DateTime createdAt;
  final String message;
  final int? userId;

  WalletHistory({
    required this.id,
    required this.transactionId,
    required this.transactionType,
    required this.type,
    required this.amount,
    required this.status,
    this.currency = 'SGD',
    required this.createdAt,
    required this.message,
    this.userId,
  });

  bool get isTip => transactionType.toUpperCase() == 'TIP';
  bool get isCredit => type.toLowerCase() == 'credit';

  String get displayTitle {
    if (isTip) return 'Tip';
    if (transactionType.isNotEmpty) {
      // Capitalize first letter of words or return as is
      return transactionType;
    }
    return isCredit ? 'Earning' : 'Payment';
  }

  factory WalletHistory.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    String formattedAmount = '0.00';
    if (rawAmount is num) {
      formattedAmount = rawAmount.toStringAsFixed(2);
    } else if (rawAmount != null) {
      formattedAmount = rawAmount.toString();
    }

    DateTime parsedDate;
    try {
      parsedDate = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString()).toLocal()
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final idVal = json['id'] is int
        ? json['id'] as int
        : (int.tryParse(json['id']?.toString() ?? '0') ?? 0);

    final userIdVal = json['userId'] is int
        ? json['userId'] as int
        : int.tryParse(json['userId']?.toString() ?? '');

    return WalletHistory(
      id: idVal,
      userId: userIdVal,
      transactionId: json['transactionId']?.toString() ?? idVal.toString(),
      transactionType: (json['transactionType']?.toString() ?? '').toUpperCase(),
      type: (json['type']?.toString() ?? 'credit').toLowerCase(),
      amount: formattedAmount,
      status: json['status']?.toString() ?? 'SUCCESS',
      currency: json['currency']?.toString() ?? 'SGD',
      createdAt: parsedDate,
      message: json['message']?.toString() ?? '',
    );
  }
}