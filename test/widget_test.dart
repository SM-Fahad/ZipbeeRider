import 'package:ZipBee_Driver/features/wallet_history/model/wallet_history_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletHistory Model Tests', () {
    test('Correctly parses TIP transactionType with amount, currency, and message', () {
      final json = {
        "id": 123,
        "userId": 45,
        "amount": 5.00,
        "type": "credit",
        "transactionType": "TIP",
        "status": "SUCCESS",
        "currency": "SGD",
        "message": "Tip of \$5.00 SGD received from John for order #101.",
        "createdAt": "2026-09-09T14:55:00.000Z"
      };

      final history = WalletHistory.fromJson(json);

      expect(history.id, 123);
      expect(history.userId, 45);
      expect(history.amount, "5.00");
      expect(history.type, "credit");
      expect(history.transactionType, "TIP");
      expect(history.isTip, isTrue);
      expect(history.isCredit, isTrue);
      expect(history.displayTitle, "Tip");
      expect(history.currency, "SGD");
      expect(history.message, "Tip of \$5.00 SGD received from John for order #101.");
      expect(history.status, "SUCCESS");
    });
  });
}
