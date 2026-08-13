import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await _messaging.getToken();
    print("=== [FCM TOKEN HP KAMU]: $token ===");

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    
    await _localNotifications.initialize(settings: initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        await _localNotifications.show(
          id: notification.hashCode,
          title: notification.title ?? '',
          body: notification.body ?? '',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'aeroponik_channel', 
              'Notifikasi Utama Aeroponik', 
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  // ========================================================
  // FUNGSI BARU: PEMICU NOTIFIKASI OTOMATIS SECARA LOKAL
  // ========================================================
  Future<void> pemicuNotifikasiLokal(String judul, String isi) async {
      await _localNotifications.show(
        id: 99, // Tambahkan 'id:' sebelum angka 99
        title: judul, // Tambahkan 'title:' sebelum variabel judul
        body: isi, // Tambahkan 'body:' sebelum variabel isi
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'aeroponik_local_channel', 
            'Notifikasi Deteksi Sensor', 
            importance: Importance.max,   
            priority: Priority.high,       
            icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}