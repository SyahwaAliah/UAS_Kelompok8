import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// -------------------------------------------------------------------
// MODEL
// -------------------------------------------------------------------

enum NotificationType { jadwal, revisi, pesan, selesai }

/// Satu item di daftar notifikasi (halaman notification_page.dart).
class AppNotification {
  final int id;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime time;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      description: description,
      time: time,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Label waktu, contoh: Hari ini, Kemarin, 3 hari lalu
  String get timeLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);
    final diff = today.difference(date).inDays;

    if (diff <= 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    return '$diff hari lalu';
  }
}

// -------------------------------------------------------------------
// SERVICE
// -------------------------------------------------------------------

/// Cukup diinisialisasi SATU KALI di main.dart.
/// Setelah itu dipanggil dari halaman mana pun lewat
/// NotificationService.instance (tidak perlu di-copy ke tiap halaman).
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'skripsi_channel';
  static const String _channelName = 'Pengingat Skripsi';
  static const String _channelDesc =
      'Pengingat jadwal bimbingan dan deadline revisi';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Notifikasi sistem hanya aktif di Android & iOS.
  /// Di platform lain (Chrome, Windows) daftar notifikasi
  /// di dalam aplikasi tetap berjalan.
  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  // ---------------------------------------------------------------
  // INIT & IZIN
  // ---------------------------------------------------------------

  Future<void> init() async {
    if (_initialized || !_supported) return;

    try {
      tz_data.initializeTimeZones();
      // Zona waktu tetap WIB. Ganti jika aplikasi dipakai di zona lain.
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      await _plugin.initialize(settings: settings);

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Meminta izin notifikasi (Android 13+ dan iOS).
  Future<bool> requestPermission() async {
    if (!_initialized) return false;

    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }

      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    } catch (e) {
      debugPrint('requestPermission error: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------
  // PENGINGAT TERJADWAL
  // ---------------------------------------------------------------

  /// Pengingat jadwal bimbingan. Default: 1 jam sebelum waktu bimbingan.
  /// Mengembalikan false jika waktu pengingat sudah lewat atau gagal.
  Future<bool> scheduleBimbingan({
    required int id,
    required DateTime waktuBimbingan,
    String? dosen,
    Duration sebelum = const Duration(hours: 1),
  }) {
    return _schedule(
      id: id,
      title: 'Jadwal Bimbingan',
      body: dosen == null
          ? 'Bimbingan kamu akan segera dimulai.'
          : 'Bimbingan dengan $dosen akan segera dimulai.',
      when: waktuBimbingan.subtract(sebelum),
    );
  }

  /// Pengingat deadline revisi. Default: 1 hari sebelum deadline.
  Future<bool> scheduleDeadlineRevisi({
    required int id,
    required DateTime deadline,
    String? bab,
    Duration sebelum = const Duration(days: 1),
  }) {
    return _schedule(
      id: id,
      title: 'Deadline Revisi',
      body: bab == null
          ? 'Deadline revisi kamu sudah dekat.'
          : 'Deadline revisi $bab sudah dekat.',
      when: deadline.subtract(sebelum),
    );
  }

  Future<bool> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if (!_initialized) return false;

    if (when.isBefore(DateTime.now())) return false;

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      return true;
    } catch (e) {
      debugPrint('schedule error: $e');
      return false;
    }
  }

  Future<void> cancel(int id) async {
    if (!_initialized) return;

    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;

    await _plugin.cancelAll();
  }

  // ---------------------------------------------------------------
  // RIWAYAT NOTIFIKASI (untuk notification_page.dart)
  // ---------------------------------------------------------------

  /// Sementara disimpan di memori (hilang saat aplikasi ditutup).
  /// Nanti bisa dipindah ke sqflite. Data awal di bawah hanya contoh,
  /// hapus _sampleData() jika sudah tidak diperlukan.
  final ValueNotifier<List<AppNotification>> notifications =
      ValueNotifier<List<AppNotification>>(_sampleData());

  int _nextId = 100;

  int get unreadCount => notifications.value.where((n) => !n.isRead).length;

  /// Menampilkan notifikasi sekarang sekaligus mencatatnya ke riwayat.
  Future<void> showNow({
    required NotificationType type,
    required String title,
    required String description,
  }) async {
    final id = _nextId++;

    notifications.value = [
      AppNotification(
        id: id,
        type: type,
        title: title,
        description: description,
        time: DateTime.now(),
      ),
      ...notifications.value,
    ];

    if (!_initialized) return;

    try {
      await _plugin.show(
        id: id,
        title: title,
        body: description,
        notificationDetails: _details,
      );
    } catch (e) {
      debugPrint('showNow error: $e');
    }
  }

  void markAsRead(int id) {
    notifications.value = [
      for (final n in notifications.value)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllAsRead() {
    notifications.value = [
      for (final n in notifications.value) n.copyWith(isRead: true),
    ];
  }

  void clearAll() {
    notifications.value = [];
  }

  static List<AppNotification> _sampleData() {
    final now = DateTime.now();

    return [
      AppNotification(
        id: 1,
        type: NotificationType.jadwal,
        title: 'Jadwal Bimbingan',
        description: 'Bimbingan kamu dijadwalkan pada Senin, 12 Oktober 2026 pukul 09.00.',
        time: now,
      ),
      AppNotification(
        id: 2,
        type: NotificationType.revisi,
        title: 'Revisi Baru',
        description: 'Dosen memberikan revisi pada Bab 3. Silakan cek detail revisi kamu.',
        time: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: 3,
        type: NotificationType.pesan,
        title: 'Pesan Baru',
        description: 'Dr. Budi Santoso mengirimkan pesan baru melalui chat.',
        time: now.subtract(const Duration(days: 2)),
      ),
      AppNotification(
        id: 4,
        type: NotificationType.selesai,
        title: 'Bimbingan Selesai',
        description: 'Sesi bimbingan sebelumnya telah selesai. Lihat riwayat bimbingan untuk detail.',
        time: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
  }
}
