import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posbankum/firebase_options.dart';
import '../../../app/routes/app_routes.dart';
import 'api_service.dart';

class NotificationHelper {
  static final NotificationHelper instance = NotificationHelper._();
  NotificationHelper._();

  FirebaseMessaging? _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Inisialisasi Firebase menggunakan opsi konfigurasi multiplatform (Android/iOS)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Inisialisasi FirebaseMessaging setelah FirebaseApp berhasil terbuat
      _fcm = FirebaseMessaging.instance;
      
      // Request permission
      await _fcm!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM Token
      String? token = await _fcm!.getToken();
      if (token != null) {
        print("FCM Token: $token");
        // Simpan token ke storage lokal
        GetStorage().write('fcm_token', token);
        // Kirim token ke backend jika user sudah login
        _sendTokenToBackend(token);
      }

      // Listen for token refresh
      _fcm!.onTokenRefresh.listen((newToken) {
        GetStorage().write('fcm_token', newToken);
        _sendTokenToBackend(newToken);
      });

      // 2. Inisialisasi Local Notifications untuk Android & iOS
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onTapLocalNotification,
      );

      // Setup Android Notification Channel dengan Suara Kustom
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'posbankum_high_channel', // id
        'Posbankum Notifications', // name
        description: 'Digunakan untuk pesan obrolan dan update penting pengaduan.', // description
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notif_sound'), // file suara: res/raw/notif_sound.mp3
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 3. Handle status notifikasi ketika aplikasi sedang terbuka (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Menerima notifikasi foreground: ${message.notification?.title}");
        _showLocalNotification(message);
      });

      // 4. Handle status notifikasi ketika aplikasi berada di Background tapi tidak tertutup
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Notifikasi ditap dari background state");
        _handleNotificationRouting(message.data);
      });

      // 5. Handle status notifikasi ketika aplikasi mati/tertutup total (Terminated)
      RemoteMessage? initialMessage = await _fcm!.getInitialMessage();
      if (initialMessage != null) {
        print("Notifikasi memicu pembukaan aplikasi dari terminated state");
        _handleNotificationRouting(initialMessage.data);
      }

      _initialized = true;
    } catch (e) {
      print("Firebase/Messaging gagal diinisialisasi (abaikan jika google-services.json belum dipasang): $e");
    }
  }

  // Menampilkan notifikasi banner di foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'posbankum_high_channel',
        'Posbankum Notifications',
        channelDescription: 'Digunakan untuk pesan obrolan dan update penting pengaduan.',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('notif_sound'),
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'notif_sound.caf',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Simpan payload data sebagai string JSON untuk dibaca saat ditap
      final payloadData = message.data.toString();

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
        payload: payloadData,
      );
    }
  }

  // Callback ketika Local Notification foreground ditap oleh user
  void _onTapLocalNotification(NotificationResponse response) {
    if (response.payload != null) {
      // Parse string representation of map ke Map asli
      // Format payload di flutter_local_notifications adalah string data
      try {
        final data = _parsePayloadString(response.payload!);
        _handleNotificationRouting(data);
      } catch (e) {
        print("Gagal parse payload data: $e");
      }
    }
  }

  // Logika Router Dinamis berdasarkan Role dan Kategori Notifikasi
  void _handleNotificationRouting(Map<String, dynamic> data) {
    final role = GetStorage().read('user')?['role']?.toString().toLowerCase() ?? 'warga';
    final type = data['type']?.toString().toLowerCase() ?? '';
    final refTable = data['ref_table']?.toString().toLowerCase() ?? '';
    final refId = data['ref_id']?.toString() ?? '';
    final idPengaduan = data['id_pengaduan']?.toString() ?? '';

    // A. PESAN CHAT (Masuk ke ruang obrolan langsung)
    if (type == 'chat' || refTable == 'chat') {
      final targetId = idPengaduan.isNotEmpty ? idPengaduan : refId;
      if (targetId.isNotEmpty) {
        if (role == 'paralegal') {
          Get.toNamed(AppRoutes.DETAIL_CHAT_PARALEGAL, arguments: targetId);
        } else {
          Get.toNamed(AppRoutes.DETAIL_CHAT_WARGA, arguments: targetId);
        }
      }
      return;
    }

    // B. DETAIL PENGADUAN / KASUS
    if (refTable == 'pengaduan' && refId.isNotEmpty) {
      if (role == 'paralegal') {
        Get.toNamed(AppRoutes.DETAIL_KASUS_PARALEGAL, arguments: {'id': refId});
      } else {
        Get.toNamed(AppRoutes.DETAIL_KASUS, arguments: refId);
      }
      return;
    }

    // C. DETAIL KEGIATAN LAPANGAN (Paralegal saja)
    if (refTable == 'kegiatan' && refId.isNotEmpty) {
      if (role == 'paralegal') {
        Get.toNamed(AppRoutes.DETAIL_KEGIATAN, arguments: refId);
      }
      return;
    }

    // D. FALLBACK (Masuk ke Halaman List Notifikasi Utama)
    if (role == 'paralegal') {
      Get.toNamed(AppRoutes.NOTIFIKASI_PARALEGAL);
    } else {
      // Warga bisa masuk ke tab notifikasi lewat dashboard controller
      // Karena warga dashboard menggunakan index 0 untuk tab notifikasi
      try {
        Get.offAllNamed(AppRoutes.WARGA_DASHBOARD);
      } catch (_) {}
    }
  }

  // Helper untuk parsing payload string format "{key: value, ...}" kembali ke Map
  Map<String, dynamic> _parsePayloadString(String payload) {
    final Map<String, dynamic> map = {};
    // Bersihkan karakter kurung kurawal
    String clean = payload.trim();
    if (clean.startsWith('{') && clean.endsWith('}')) {
      clean = clean.substring(1, clean.length - 1);
    }
    final List<String> pairs = clean.split(',');
    for (var pair in pairs) {
      final List<String> parts = pair.split(':');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts.sublist(1).join(':').trim();
        map[key] = value;
      }
    }
    return map;
  }

  // Mengirim FCM registration token ke database backend (jika login)
  Future<void> _sendTokenToBackend(String token) async {
    final loggedIn = GetStorage().read('token') != null;
    if (!loggedIn) return;

    try {
      // Kirim via Dio API Service
      // Jika endpoint /profile/fcm-token belum diimplementasikan backend web, ini akan gagal secara aman (fail silently)
      final dio = ApiService().dio;
      await dio.post('/profile/fcm-token', data: {
        'fcm_token': token,
      });
      print("Token FCM berhasil didaftarkan ke server backend.");
    } catch (_) {
      // Fail silently agar tidak mengganggu operasional app utama
    }
  }
}
