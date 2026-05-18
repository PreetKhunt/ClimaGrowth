import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class _NotifItem {
  final String title, body, category;
  final DateTime time;
  bool read;
  _NotifItem({required this.title, required this.body, required this.category, required this.time, this.read = false});
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotifItem> _notifs = [
    _NotifItem(title: 'Heavy Rainfall Warning', body: 'Expected 40mm rainfall in the next 6 hours. Prepare drainage.', category: 'weather_alerts', time: DateTime.now().subtract(const Duration(hours: 1))),
    _NotifItem(title: 'Irrigation Reminder', body: 'Time to water your cotton field. Soil moisture is at 52%.', category: 'irrigation_reminders', time: DateTime.now().subtract(const Duration(hours: 3))),
    _NotifItem(title: 'Market Update', body: 'Cotton prices rose to ₹6,850/quintal at Vadodara APMC.', category: 'market_updates', time: DateTime.now().subtract(const Duration(hours: 5)), read: true),
    _NotifItem(title: 'Farming Tip', body: 'Best time to apply nitrogen fertilizer is early morning before 9 AM.', category: 'farming_tips', time: DateTime.now().subtract(const Duration(days: 1)), read: true),
    _NotifItem(title: 'Heatwave Alert', body: 'Temperature may reach 42°C tomorrow. Increase irrigation frequency.', category: 'weather_alerts', time: DateTime.now().subtract(const Duration(days: 1)), read: true),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => setState(() {
              for (var n in _notifs) { n.read = true; }
            }),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: _notifs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: tt.headlineMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(kPadding),
              itemCount: _notifs.length,
              itemBuilder: (ctx, i) => _notifTile(_notifs[i], tt, i),
            ),
    );
  }

  Widget _notifTile(_NotifItem n, TextTheme tt, int index) {
    return Dismissible(
      key: Key('notif_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: kDangerRed,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => setState(() => _notifs.remove(n)),
      child: GestureDetector(
        onTap: () => setState(() => n.read = true),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(kPadding),
          decoration: BoxDecoration(
            color: n.read
                ? Theme.of(context).cardTheme.color
                : kPrimaryGreen.withOpacity(0.06),
            borderRadius: BorderRadius.circular(kRadius),
            border: Border.all(
              color: n.read ? Colors.transparent : kPrimaryGreen.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _catColor(n.category).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_catIcon(n.category), color: _catColor(n.category), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: n.read ? FontWeight.w400 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!n.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: kPrimaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(n.body, style: tt.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(Formatters.dateTime(n.time), style: tt.labelSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0);
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'weather_alerts': return kDangerRed;
      case 'irrigation_reminders': return Colors.blue.shade600;
      case 'market_updates': return Colors.purple.shade600;
      default: return kPrimaryGreen;
    }
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'weather_alerts': return Icons.thunderstorm_rounded;
      case 'irrigation_reminders': return Icons.water_drop_outlined;
      case 'market_updates': return Icons.storefront_rounded;
      default: return Icons.tips_and_updates_rounded;
    }
  }
}
