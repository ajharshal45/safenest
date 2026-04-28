import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_glow_switch.dart';
import '../widgets/bouncing_button.dart';

class ControlsScreen extends StatelessWidget {
  const ControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<FirebaseService>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Smart Controls'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildLockCard(context, service, isDark),
          const SizedBox(height: 16),
          _buildDeviceCard(context, service, isDark),
        ],
      ),
    );
  }

  Widget _buildLockCard(BuildContext context, FirebaseService service, bool isDark) {
    final isUnlocked = service.lockCommand;
    final progress = service.relockCountdown / 20.0;
    
    final lockColor = isUnlocked ? AppTheme.errorRed : (isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight);

    return GlassCard(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lockColor.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: lockColor.withValues(alpha: 0.3),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
              child: Icon(
                isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                key: ValueKey(isUnlocked),
                size: 80,
                color: lockColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isUnlocked ? 'SYSTEM UNLOCKED' : 'SYSTEM SECURED',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: lockColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isUnlocked ? 'Auto-relocking in ${service.relockCountdown}s' : 'Door is locked — default state',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (isUnlocked) ...[
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.linear,
                height: 6,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.warningAmber),
                ),
              ),
            ),
          ],
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: BouncingButton(
                  onTap: () => service.setLock(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: (!isUnlocked) ? (isDark ? AppTheme.darkSurface : AppTheme.lightSurface) : (isDark ? AppTheme.successGreenDark.withValues(alpha: 0.2) : AppTheme.successGreenLight.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: (!isUnlocked) ? (isDark ? AppTheme.darkBorder : AppTheme.lightBorder) : (isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight),
                        width: (!isUnlocked) ? 1 : 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'LOCK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: (!isUnlocked) ? (isDark ? AppTheme.darkMuted : AppTheme.lightMuted) : (isDark ? AppTheme.successGreenDark : AppTheme.successGreenLight),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BouncingButton(
                  onTap: () => service.setLock(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppTheme.errorRed.withValues(alpha: 0.2) : (isDark ? AppTheme.darkSurface : AppTheme.lightSurface),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isUnlocked ? AppTheme.errorRed : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                        width: isUnlocked ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'UNLOCK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: isUnlocked ? AppTheme.errorRed : (isDark ? AppTheme.darkMuted : AppTheme.lightMuted),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, FirebaseService service, bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Device Controls',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildDeviceRow(
            context: context,
            icon: Icons.lightbulb_outline_rounded,
            title: 'Smart Lights',
            subtitle: 'Relay 1 — motion activated',
            value: service.lightStatus,
            activeColor: AppTheme.warningAmber,
            onChanged: (val) => service.setLight(val ? 1 : 0),
            isDark: isDark,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder, height: 1),
          ),
          _buildDeviceRow(
            context: context,
            icon: Icons.cyclone_rounded,
            title: 'Exhaust Fan',
            subtitle: 'Relay 2 — manual control',
            value: service.motorStatus,
            activeColor: isDark ? AppTheme.primaryCyan : AppTheme.primaryBlue,
            onChanged: (val) => service.setMotor(val ? 1 : 0),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: value ? activeColor.withValues(alpha: 0.15) : (isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: value ? activeColor.withValues(alpha: 0.5) : Colors.transparent,
            )
          ),
          child: Icon(
            icon,
            color: value ? activeColor : (isDark ? AppTheme.darkMuted : AppTheme.lightMuted),
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
        AnimatedGlowSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
        ),
      ],
    );
  }
}
