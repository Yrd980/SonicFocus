import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/sonicfocus_theme.dart';
import '../ui/components/glass_panel.dart';
import 'voice_profiles_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final t = context.sf;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: t.backgroundBase))),
          Positioned(top: -120, left: -80, child: _orb(t.primary.withValues(alpha: 0.2))),
          Positioned(bottom: -120, right: -80, child: _orb(t.secondary.withValues(alpha: 0.18))),
          Center(
            child: Padding(
              padding: EdgeInsets.all(t.containerPadding),
              child: GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(colors: [Color(0xFFADC6FF), Color(0xFFD0BCFF)]).createShader(r),
                    child: Text('SonicFocus', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  Text('Focus on the voice that matters.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: t.primary, foregroundColor: const Color(0xFF002E6A)),
                    onPressed: () => Navigator.pushNamed(context, VoiceProfilesPage.routeName),
                    child: const Text('Start Listening'),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color c) => Container(width: 260, height: 260, decoration: BoxDecoration(color: c, shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: const SizedBox()));
}
