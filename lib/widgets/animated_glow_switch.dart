import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';

class AnimatedGlowSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const AnimatedGlowSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    
    final trackColor = value 
        ? activeColor.withValues(alpha: isDark ? 0.3 : 0.4)
        : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder);
        
    final shadowColor = value
        ? activeColor.withValues(alpha: isDark ? 0.6 : 0.3)
        : Colors.transparent;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: trackColor,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: value ? activeColor : (isDark ? AppTheme.darkMuted.withValues(alpha: 0.3) : AppTheme.lightMuted.withValues(alpha: 0.3)),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: value ? 26 : 4,
              right: value ? 4 : 26,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? activeColor : (isDark ? AppTheme.darkMuted : AppTheme.lightMuted),
                  boxShadow: value ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ] : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
