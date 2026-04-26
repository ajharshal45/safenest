import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_service.dart';
import '../theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<FirebaseService>();

    final isForcedEntry = service.door && !service.lockCommand;
    final isGasAlert = service.gasAlert || service.gas >= 2500;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeNest'),
        actions: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: service.isConnected ? AppTheme.successText : AppTheme.errorText,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                service.isConnected ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  color: service.isConnected ? AppTheme.successText : AppTheme.errorText,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
            ],
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (isGasAlert)
            _buildAlertBanner(
              '⚠️ Gas Critical — Dangerous levels detected!',
            ),
          if (isForcedEntry)
            _buildAlertBanner(
              '⚠️ Forced Entry Detected — Door opened without unlock!',
            ),
          _buildGasCard(context, service, isGasAlert),
          _buildMotionCard(context, service),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: AppTheme.errorBorder,
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.errorText,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGasCard(BuildContext context, FirebaseService service, bool isAlert) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isAlert ? AppTheme.errorBorder : AppTheme.cardBorder,
          width: isAlert ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MQ-2 Sensor',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAlert ? AppTheme.errorBorder : AppTheme.successBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isAlert ? 'ALERT' : 'OK',
                    style: TextStyle(
                      color: isAlert ? AppTheme.errorText : AppTheme.successText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${service.gas}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ppm',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                      color: AppTheme.primaryContainer,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotionCard(BuildContext context, FirebaseService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Motion Detection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMotionRow('PIR Sensor 1', service.pir1),
            const Divider(color: AppTheme.cardBorder, height: 24),
            _buildMotionRow('PIR Sensor 2', service.pir2),
            const SizedBox(height: 16),
            Text(
              'Lights auto-on on detection • off after 15s',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotionRow(String label, bool isDetected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            Text(
              isDetected ? 'DETECTED' : 'NONE',
              style: TextStyle(
                color: isDetected ? AppTheme.successText : AppTheme.mutedText,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDetected ? AppTheme.successText : AppTheme.mutedText,
                boxShadow: isDetected
                    ? [BoxShadow(color: AppTheme.successText.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)]
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

}
