import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

class StatusDot extends StatelessWidget {
  final String status;
  final double size;

  const StatusDot({
    super.key,
    required this.status,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );

    if (status == 'critical') {
      return dot
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.3, 1.3),
            duration: 1500.ms,
            curve: Curves.easeInOut,
          );
    }

    return dot;
  }
}
