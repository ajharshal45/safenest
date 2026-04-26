import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../theme.dart';

class ControlsScreen extends StatelessWidget {
  const ControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controls'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildLockCard(context, service),
          _buildDeviceCard(context, service),
        ],
      ),
    );
  }

  Widget _buildLockCard(BuildContext context, FirebaseService service) {
    final isUnlocked = service.lockCommand;
    final progress = service.relockCountdown / 20.0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppTheme.cardBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              isUnlocked ? Icons.lock_open : Icons.lock,
              size: 80,
              color: isUnlocked ? AppTheme.errorText : AppTheme.successText,
            ),
            const SizedBox(height: 16),
            Text(
              isUnlocked ? 'UNLOCKED' : 'LOCKED',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUnlocked ? 'Auto-relocking in ${service.relockCountdown}s' : 'Door is secured — default state',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppTheme.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.warningText),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => service.setLock(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successBg,
                      foregroundColor: AppTheme.successText,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Lock Door', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => service.setLock(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorBorder,
                      foregroundColor: AppTheme.errorText,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Unlock Door', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, FirebaseService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDeviceRow(
              context: context,
              icon: Icons.lightbulb_outline,
              title: 'Lights',
              subtitle: 'Relay 1 — motion activated',
              value: service.lightStatus,
              onChanged: (val) => service.setLight(val ? 1 : 0),
            ),
            const Divider(color: AppTheme.cardBorder, height: 24),
            _buildDeviceRow(
              context: context,
              icon: Icons.cyclone, // Fan-like icon for motor
              title: 'DC Motor',
              subtitle: 'Relay 2 — manual control',
              value: service.motorStatus,
              onChanged: (val) => service.setMotor(val ? 1 : 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: value ? AppTheme.primaryContainer.withValues(alpha: 0.2) : AppTheme.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: value ? AppTheme.primaryContainer : AppTheme.mutedText,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primaryContainer,
          activeTrackColor: AppTheme.primaryContainer.withValues(alpha: 0.3),
          inactiveThumbColor: AppTheme.mutedText,
          inactiveTrackColor: AppTheme.background,
        ),
      ],
    );
  }
}
