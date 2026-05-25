import 'package:flutter/material.dart';

import 'pages/focus_mode_page.dart';
import 'pages/live_listening_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/voice_profiles_page.dart';
import 'theme/sonicfocus_theme.dart';

void main() {
  runApp(const SonicFocusApp());
}

class SonicFocusApp extends StatelessWidget {
  const SonicFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SonicFocus',
      debugShowCheckedModeBanner: false,
      theme: buildSonicFocusTheme(),
      initialRoute: OnboardingPage.routeName,
      routes: {
        OnboardingPage.routeName: (_) => const OnboardingPage(),
        VoiceProfilesPage.routeName: (_) => const VoiceProfilesPage(),
        LiveListeningPage.routeName: (_) => const LiveListeningPage(),
        FocusModePage.routeName: (_) => const FocusModePage(),
      },
    );
  }
}
