import 'package:flutter/material.dart';

import '../../theme/sonicfocus_theme.dart';

class AudioBars extends StatelessWidget {
  const AudioBars({
    required this.values,
    super.key,
    this.height = 48,
    this.color,
    this.dimmed = false,
  });

  final List<int> values;
  final double height;
  final Color? color;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final t = context.sf;
    final barColor = color ?? t.primary;
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values
            .map(
              (value) => Expanded(
                child: FractionallySizedBox(
                  heightFactor: (value / 8).clamp(0.12, 1),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: barColor.withValues(alpha: dimmed ? 0.32 : 0.72),
                      boxShadow: dimmed
                          ? null
                          : [
                              BoxShadow(
                                color: barColor.withValues(alpha: 0.28),
                                blurRadius: 10,
                              ),
                            ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
