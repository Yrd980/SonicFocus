import 'package:flutter/material.dart';

import '../theme/sonicfocus_theme.dart';
import '../ui/components/glass_panel.dart';
import 'focus_mode_page.dart';

class LiveListeningPage extends StatelessWidget {
  const LiveListeningPage({super.key});
  static const routeName = '/live-listening';

  @override
  Widget build(BuildContext context) {
    final t = context.sf;
    return Scaffold(
      appBar: AppBar(title: const Text('Live Listening')),
      body: Padding(
        padding: EdgeInsets.all(t.containerPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Listening to your environment...', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          GlassPanel(
            child: SizedBox(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(36, (i) {
                  final h = 24.0 + (i % 7) * 14.0;
                  return Container(
                    width: 3,
                    height: h,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFFADC6FF), Color(0xFFD0BCFF)]),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Detected voices are continuously clustered and tracked.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.onSurfaceVariant)),
          const Spacer(),
          FilledButton(onPressed: () => Navigator.pushNamed(context, FocusModePage.routeName), child: const Text('Open Focus Mode')),
        ]),
      ),
    );
  }
}
