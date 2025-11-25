import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:auri_app/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Necesario SIEMPRE
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("📩 Background message: ${message.messageId}");
}
