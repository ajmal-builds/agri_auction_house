import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {

  static Future<void> initialize() async {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Notification received: ${message.notification?.title}");
    });

  }
}
