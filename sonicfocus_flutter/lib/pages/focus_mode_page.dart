import 'package:flutter/material.dart';

import '../theme/sonicfocus_theme.dart';
import '../ui/components/glass_panel.dart';

class FocusModePage extends StatefulWidget {
  const FocusModePage({super.key});
  static const routeName = '/focus-mode';

  @override
  State<FocusModePage> createState() => _FocusModePageState();
}

class _FocusModePageState extends State<FocusModePage> {
  double strength = 1;

  @override
  Widget build(BuildContext context) {
    final t = context.sf;
    final label = ['Low', 'Medium', 'High'][strength.toInt()];
    return Scaffold(
      appBar: AppBar(title: const Text('Focus Mode')),
      body: Padding(
        padding: EdgeInsets.all(t.containerPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Focused on Voice A', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          GlassPanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Focus Strength', style: Theme.of(context).textTheme.labelMedium),
                Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: t.primary)),
              ]),
              Slider(value: strength, divisions: 2, min: 0, max: 2, onChanged: (v) => setState(() => strength = v)),
            ]),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            child: Text('MVP mode: target voice enhancement + non-target attenuation.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.onSurfaceVariant)),
          ),
        ]),
      ),
    );
  }
}
