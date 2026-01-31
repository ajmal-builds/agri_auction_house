import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final _db = FirebaseFirestore.instance;

  Future<void> send({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
