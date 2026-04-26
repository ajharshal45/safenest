import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../theme.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<FirebaseService>();
    final timeFormat = DateFormat('HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(child: _buildStatusCard(context, 'Gas Alert', service.gasAlert)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatusCard(context, 'Security Alert', service.securityAlert)),
              ],
            ),
          ),
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: service.activityLog.isEmpty
                  ? const Center(child: Text('No recent activity'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: service.activityLog.length,
                      separatorBuilder: (context, idx) => const Divider(color: AppTheme.cardBorder),
                      itemBuilder: (context, index) {
                        final log = service.activityLog[index];
                        return _buildLogEntry(log, timeFormat);
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Last updated: ${timeFormat.format(DateTime.now())}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, String title, bool isAlert) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isAlert ? AppTheme.errorBorder : AppTheme.successBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isAlert ? 'YES' : 'NO',
              style: TextStyle(
                color: isAlert ? AppTheme.errorText : AppTheme.successText,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(LogEntry log, DateFormat timeFormat) {
    Color dotColor;
    switch (log.colorType) {
      case 'red':
        dotColor = AppTheme.errorText;
        break;
      case 'green':
        dotColor = AppTheme.successText;
        break;
      case 'yellow':
        dotColor = AppTheme.warningText;
        break;
      case 'blue':
        dotColor = AppTheme.primaryContainer;
        break;
      default:
        dotColor = AppTheme.mutedText;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            timeFormat.format(log.timestamp),
            style: const TextStyle(
              color: AppTheme.mutedText,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              log.message,
              style: const TextStyle(color: AppTheme.onSurfaceText),
            ),
          ),
        ],
      ),
    );
  }
}
