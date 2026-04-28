import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/pulsing_indicator.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<FirebaseService>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final timeFormat = DateFormat('HH:mm:ss');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Activity Logs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(child: _buildStatusBadge(context, 'Gas System', service.gasAlert, isDark)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatusBadge(context, 'Security', service.securityAlert, isDark)),
              ],
            ),
          ),
          Expanded(
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: service.activityLog.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_rounded, size: 48, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted),
                          const SizedBox(height: 16),
                          Text('No recent activity', style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: service.activityLog.length,
                      itemBuilder: (context, index) {
                        final log = service.activityLog[index];
                        return _buildLogEntry(log, timeFormat, isDark);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String title, bool isAlert, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      borderRadius: 16,
      child: Column(
        children: [
          Text(
            title, 
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
            )
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isAlert 
                  ? AppTheme.errorRed.withValues(alpha: 0.15) 
                  : (isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isAlert 
                    ? AppTheme.errorRed 
                    : (isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight),
                width: 1,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                if (isAlert) 
                  const Padding(
                    padding: EdgeInsets.only(right: 6.0),
                    child: PulsingIndicator(color: AppTheme.errorRed, isPulsing: true),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight,
                      ),
                    ),
                  ),
                Text(
                  isAlert ? 'ALERT' : 'NORMAL',
                  style: TextStyle(
                    color: isAlert 
                        ? AppTheme.errorRed 
                        : (isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(LogEntry log, DateFormat timeFormat, bool isDark) {
    Color dotColor;
    switch (log.colorType) {
      case 'red':
        dotColor = AppTheme.errorRed;
        break;
      case 'green':
        dotColor = isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight;
        break;
      case 'yellow':
        dotColor = AppTheme.warningAmber;
        break;
      case 'blue':
        dotColor = isDark ? AppTheme.primaryCyan : AppTheme.primaryBlue;
        break;
      default:
        dotColor = isDark ? AppTheme.darkMuted : AppTheme.lightMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.message,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  timeFormat.format(log.timestamp),
                  style: TextStyle(
                    color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
