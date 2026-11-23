import 'package:flutter/material.dart';

import 'jadwal_theme.dart';
import 'notification_service.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.jadwal:
        return Icons.calendar_month_outlined;
      case NotificationType.revisi:
        return Icons.edit_note;
      case NotificationType.pesan:
        return Icons.chat_bubble_outline;
      case NotificationType.selesai:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkOlive = Color(0xFF523B39);
    const accent = Color(0xFF96C1C5);

    final service = NotificationService.instance;

    return AnimatedPage(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF0DE),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFF0DE),
                Color(0xFFEAF3F2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 17,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifikasi',
                              style: TextStyle(
                                color: darkOlive,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Informasi terbaru bimbingan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'read') {
                            await service.markAllAsRead();
                          }

                          if (value == 'clear') {
                            await service.clearAll();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'read',
                            child: Text('Tandai semua dibaca'),
                          ),
                          PopupMenuItem(
                            value: 'clear',
                            child: Text('Hapus riwayat'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ValueListenableBuilder<
                      List<AppNotification>>(
                    valueListenable: service.notifications,
                    builder: (context, items, _) {
                      if (items.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  size: 58,
                                  color: Color(0xFF96C1C5),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Belum ada notifikasi',
                                  style: TextStyle(
                                    color: darkOlive,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Notifikasi akan muncul di sini.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            18, 10, 18, 25),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final icon = _iconFor(item.type);

                          final background = item.isRead
                              ? const Color(0xFFEAF3F2)
                              : const Color(0xFFE5F0EF);

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: item.isRead
                                  ? null
                                  : Border.all(
                                color: accent.withOpacity(0.65),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 9,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: item.isRead
                                  ? null
                                  : () => service.markAsRead(item.id),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: background,
                                        borderRadius:
                                        BorderRadius.circular(15),
                                      ),
                                      child: Icon(
                                        icon,
                                        color: const Color(0xFF694A47),
                                        size: 23,
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title,
                                                  style: const TextStyle(
                                                    color: darkOlive,
                                                    fontSize: 14,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (!item.isRead)
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 6),
                                                  child: CircleAvatar(
                                                    radius: 4,
                                                    backgroundColor: accent,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            item.description,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          Text(
                                            item.timeLabel,
                                            style: const TextStyle(
                                              color: Color(0xFF694A47),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}