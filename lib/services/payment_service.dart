import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  Future<void> markPaymentPaid(String orderId) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({
      'paymentStatus': 'paid',
    });
  }
}
