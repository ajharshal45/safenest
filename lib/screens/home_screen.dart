import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_service.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/pulsing_indicator.dart';
import '../widgets/bouncing_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<FirebaseService>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final isForcedEntry = service.door && !service.lockCommand;
    final isGasAlert = service.gasAlert || service.gas >= 2500;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('SafeNest Dashboard'),
        actions: [
          BouncingButton(
            onTap: () => themeProvider.toggleTheme(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              ),
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                size: 20,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: service.isConnected 
                  ? AppTheme.successGreenDark.withValues(alpha: 0.2) 
                  : AppTheme.errorRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: service.isConnected ? AppTheme.successGreenDark : AppTheme.errorRed,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                PulsingIndicator(
                  color: service.isConnected ? AppTheme.successGreenDark : AppTheme.errorRed,
                  isPulsing: service.isConnected,
                ),
                const SizedBox(width: 8),
                Text(
                  service.isConnected ? 'Connected' : 'Offline',
                  style: TextStyle(
                    color: service.isConnected 
                        ? (isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight) 
                        : AppTheme.errorRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 100), // padding for bottom nav
        physics: const BouncingScrollPhysics(),
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: isGasAlert
                ? _buildAlertBanner(context, '⚠️ Gas Critical — Dangerous levels detected!', isDark)
                : const SizedBox.shrink(),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: isForcedEntry
                ? _buildAlertBanner(context, '⚠️ Forced Entry Detected — Door opened without unlock!', isDark)
                : const SizedBox.shrink(),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Safety Overview',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
              ),
            ),
          ),
          _buildGasCard(context, service, isGasAlert, isDark),
          
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Security Monitoring',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
              ),
            ),
          ),
          _buildMotionCard(context, service, isDark),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(BuildContext context, String text, bool isDark) {
    return Container(
      key: ValueKey(text),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.errorRed, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorRed.withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          const PulsingIndicator(color: AppTheme.errorRed),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.errorRed,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGasCard(BuildContext context, FirebaseService service, bool isAlert, bool isDark) {
    final primaryColor = isDark ? AppTheme.primaryCyan : AppTheme.primaryBlue;

    return GlassCard(
      isAlert: isAlert,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gas & Fire Safety',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MQ-2 Sensor Data',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isAlert 
                      ? AppTheme.errorRed.withValues(alpha: 0.2) 
                      : (isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isAlert ? AppTheme.errorRed : (isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight),
                    width: 1,
                  ),
                ),
                child: Text(
                  isAlert ? 'DANGER' : 'SAFE',
                  style: TextStyle(
                    color: isAlert ? AppTheme.errorRed : (isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${service.gas}',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: isAlert ? AppTheme.errorRed : (isDark ? AppTheme.darkText : AppTheme.lightText),
                  shadows: isAlert ? [
                    BoxShadow(color: AppTheme.errorRed.withValues(alpha: 0.5), blurRadius: 12)
                  ] : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ppm',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 4095,
                lineBarsData: [
                  LineChartBarData(
                    spots: service.gasHistory
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                        .toList(),
                    isCurved: true,
                    color: isAlert ? AppTheme.errorRed : primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          (isAlert ? AppTheme.errorRed : primaryColor).withValues(alpha: 0.4),
                          (isAlert ? AppTheme.errorRed : primaryColor).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    shadow: Shadow(
                      color: (isAlert ? AppTheme.errorRed : primaryColor).withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
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

  Widget _buildMotionCard(BuildContext context, FirebaseService service, bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Motion Detection',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildMotionRow('Motion', service.pir1, isDark),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted),
              const SizedBox(width: 8),
              Text(
                'Lights auto-on on detection • off after 15s',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotionRow(String label, bool isDetected, bool isDark) {
    final successColor = isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight;
    final mutedColor = isDark ? AppTheme.darkMuted : AppTheme.lightMuted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Row(
          children: [
            Text(
              isDetected ? 'DETECTED' : 'STANDBY',
              style: TextStyle(
                color: isDetected ? successColor : mutedColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 12),
            if (isDetected)
              PulsingIndicator(color: successColor)
            else
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mutedColor.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
