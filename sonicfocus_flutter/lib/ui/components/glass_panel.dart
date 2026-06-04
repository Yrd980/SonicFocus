import 'dart:ui';

import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.active = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final glow = active
        ? const Color(0xFFADC6FF).withValues(alpha: 0.18)
        : Colors.transparent;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: glow, blurRadius: 20, offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
              ),
              color: const Color(0x08FFFFFF),
              border: Border.all(
                color:
                    active ? const Color(0x55ADC6FF) : const Color(0x1AFFFFFF),
                width: active ? 1 : 0.8,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
