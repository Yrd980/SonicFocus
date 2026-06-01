import 'package:flutter/material.dart';

import '../features/voice_selector/controller/voice_selector_controller.dart';
import '../features/voice_selector/model/voice_line.dart';
import '../theme/sonicfocus_theme.dart';
import '../ui/components/glass_panel.dart';
import 'live_listening_page.dart';

class VoiceProfilesPage extends StatefulWidget {
  const VoiceProfilesPage({super.key});
  static const routeName = '/voice-profiles';

  @override
  State<VoiceProfilesPage> createState() => _VoiceProfilesPageState();
}

class _VoiceProfilesPageState extends State<VoiceProfilesPage> {
  final controller = VoiceSelectorController();

  @override
  Widget build(BuildContext context) {
    final t = context.sf;
    return Scaffold(
      appBar: AppBar(title: const Text('Detected Voices')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (_, __) => Padding(
          padding: EdgeInsets.all(t.containerPadding),
          child: Column(children: [
            ...controller.voices.map((voice) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => controller.selectVoice(voice.id),
                    child: GlassPanel(
                      active: voice.isSelected,
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(voice.label, style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 4),
                          Text(_status(voice.status), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: t.onSurfaceVariant)),
                        ])),
                        Text('${(voice.confidence * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: t.primary)),
                      ]),
                    ),
                  ),
                )),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, LiveListeningPage.routeName),
              child: Text('Focus ${controller.selectedVoice.label}'),
            )
          ]),
        ),
      ),
    );
  }

  String _status(VoiceStatus s) => switch (s) {
        VoiceStatus.speakingNow => 'Speaking now',
        VoiceStatus.nearby => 'Nearby',
        VoiceStatus.background => 'Background',
        VoiceStatus.noisy => 'Noisy',
      };
}
