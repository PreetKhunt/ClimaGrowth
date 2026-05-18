import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/alert_model.dart';
import '../utils/constants.dart';
import '../widgets/alert_card.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = AlertModel.mockAlerts();
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Alerts'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 80, color: kSecondaryGreen),
                  const SizedBox(height: 16),
                  Text('No Active Alerts', style: tt.headlineMedium?.copyWith(color: kPrimaryGreen)),
                  Text('Your region is safe right now.', style: tt.bodyMedium),
                ],
              ).animate().fadeIn(duration: 500.ms),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(kPadding),
              itemCount: alerts.length,
              itemBuilder: (ctx, i) => AlertCard(alert: alerts[i], index: i),
            ),
    );
  }
}
