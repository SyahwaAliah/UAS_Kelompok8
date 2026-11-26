import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:test/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test/database/auth_database.dart';

enum NotificationType { jadwal, revisi, pesan, selesai }

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

  factory AppNotification.fromMap(Map<String, Object?> map) {
    return AppNotification(
      id: map['id'] as int,
      type: NotificationType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => NotificationType.pesan,
      ),
      title: map['title'] as String,
      description: map['description'] as String,
      time: DateTime.parse(map['time'] as String),
      isRead: (map['is_read'] as int? ?? 0) == 1,
    );
  }

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

  String get timeLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);

    final difference = date.difference(today).inDays;

    if (difference < 0) return 'Sudah lewat';
    if (difference == 0) return 'Hari ini';
    if (difference == 1) return 'Kemarin';

    return '$difference hari yang lalu';
  }
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String channelId = 'skripsi_channel';
  static const String channelName = 'Pengingat Skripsi';
  static const String channelDescription =
      'Notifikasi informasi dan pengingat bimbingan skripsi';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final ValueNotifier<List<AppNotification>> notifications =
      ValueNotifier<List<AppNotification>>([]);

  bool _initialized = false;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  // Initialize the notification plugin.
  Future<void> init() async {
    if (_initialized || !_supported) return;

    try {
      tz_data.initializeTimeZones();
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

      await _reloadHistory();
    } catch (error) {
      debugPrint('Notification initialization error: $error');
    }
  }

  // Request permission to display notifications.
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
    } catch (error) {
      debugPrint('Notification permission error: $error');
      return false;
    }
  }

  // Save a notification to the in-app notification history.
  Future<int> addInAppNotification({
    required NotificationType type,
    required String title,
    required String description,
  }) async {
    final id = await DatabaseHelper.instance.simpanNotifikasi(
      type: type.name,
      title: title,
      description: description,
      time: DateTime.now().toIso8601String(),
    );

    await _reloadHistory();

    return id;
  }

  // Save a notification and immediately display it on the device.
  Future<void> showNow({
    required NotificationType type,
    required String title,
    required String description,
  }) async {
    int notificationId;

    try {
      notificationId = await addInAppNotification(
        type: type,
        title: title,
        description: description,
      );
    } catch (error) {
      debugPrint('Failed to save notification history: $error');

      notificationId = DateTime.now().millisecondsSinceEpoch % 2000000000;
    }

    if (!_initialized || !_supported) return;

    try {
      await _plugin.show(
        id: notificationId,
        title: title,
        body: description,
        notificationDetails: _notificationDetails,
      );
    } catch (error) {
      debugPrint('Failed to show notification: $error');
    }
  }

  // Schedule a generic notification for a future date and time.
  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String description,
    required DateTime scheduledTime,
  }) async {
    if (!_initialized || !_supported) return false;

    final scheduledDate = tz.TZDateTime(
      tz.local,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return false;
    }

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: description,
        scheduledDate: scheduledDate,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      return true;
    } catch (error) {
      debugPrint('Failed to schedule notification: $error');
      return false;
    }
  }

  // Cancel a scheduled notification using its ID.
  Future<void> cancelScheduledNotification(int id) async {
    if (!_initialized) return;

    await _plugin.cancel(id: id);
  }

  // Mark one notification as read.
  Future<void> markAsRead(int id) async {
    await DatabaseHelper.instance.tandaiNotifikasiDibaca(id);
    await _reloadHistory();
  }

  // Mark all notifications as read.
  Future<void> markAllAsRead() async {
    await DatabaseHelper.instance.tandaiSemuaNotifikasiDibaca();
    await _reloadHistory();
  }

  // Delete all notification history.
  Future<void> clearAll() async {
    await DatabaseHelper.instance.hapusSemuaNotifikasi();
    await _reloadHistory();
  }

  int get unreadCount =>
      notifications.value.where((item) => !item.isRead).length;

  // Retrieve notification history from SQLite.
  Future<void> _reloadHistory() async {
    try {
      final rows = await DatabaseHelper.instance.ambilNotifikasi();

      notifications.value = rows
          .map((row) => AppNotification.fromMap(row))
          .toList();
    } catch (error) {
      debugPrint('Failed to load notification history: $error');
    }
  }

  Future<Database> _databaseAkun() async {
    await AuthDatabase.instance.sesiAktif();

    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        penerima_id INTEGER NOT NULL,
        judul TEXT NOT NULL,
        pesan TEXT NOT NULL,
        tipe TEXT NOT NULL,
        referensi_id INTEGER,
        dibuat_pada TEXT NOT NULL,
        sudah_dibaca INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (penerima_id) REFERENCES skriva_akun(id)
      )
    ''');

    return db;
  }

  Future<int> kirimKeAkun({
    required int penerimaId,
    required String judul,
    required String pesan,
    required String tipe,
    int? referensiId,
  }) async {
    final db = await _databaseAkun();

    return db.insert('skriva_notifications', {
      'penerima_id': penerimaId,
      'judul': judul,
      'pesan': pesan,
      'tipe': tipe,
      'referensi_id': referensiId,
      'dibuat_pada': DateTime.now().toIso8601String(),
      'sudah_dibaca': 0,
    });
  }

  Future<List<Map<String, Object?>>> ambilNotifikasiAkun() async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null) return [];

    final db = await _databaseAkun();

    return db.query(
      'skriva_notifications',
      where: 'penerima_id = ?',
      whereArgs: [akun['id']],
      orderBy: 'dibuat_pada DESC, id DESC',
    );
  }

  Future<int> jumlahNotifikasiBelumDibaca() async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null) return 0;

    final db = await _databaseAkun();

    final result = Sqflite.firstIntValue(
      await db.rawQuery(
        '''
        SELECT COUNT(*)
        FROM skriva_notifications
        WHERE penerima_id = ?
          AND sudah_dibaca = 0
      ''',
        [akun['id']],
      ),
    );

    return result ?? 0;
  }

  Future<void> tandaiNotifikasiAkunDibaca(int id) async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null) return;

    final db = await _databaseAkun();

    await db.update(
      'skriva_notifications',
      {'sudah_dibaca': 1},
      where: 'id = ? AND penerima_id = ?',
      whereArgs: [id, akun['id']],
    );
  }

  Future<void> tandaiSemuaNotifikasiAkunDibaca() async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null) return;

    final db = await _databaseAkun();

    await db.update(
      'skriva_notifications',
      {'sudah_dibaca': 1},
      where: 'penerima_id = ?',
      whereArgs: [akun['id']],
    );
  }

  Future<void> hapusSemuaNotifikasiAkun() async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null) return;

    final db = await _databaseAkun();

    await db.delete(
      'skriva_notifications',
      where: 'penerima_id = ?',
      whereArgs: [akun['id']],
    );
  }
}
