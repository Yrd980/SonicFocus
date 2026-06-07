import 'package:flutter/material.dart';

import '../features/voice_selector/controller/focus_session_controller.dart';
import '../features/voice_selector/model/voice_line.dart';
import '../theme/sonicfocus_theme.dart';
import '../ui/components/audio_bars.dart';
import '../ui/components/glass_panel.dart';
import 'live_listening_page.dart';

class VoiceProfilesPage extends StatefulWidget {
  const VoiceProfilesPage({super.key});
  static const routeName = '/voice-profiles';

  @override
  State<VoiceProfilesPage> createState() => _VoiceProfilesPageState();
}

class _VoiceProfilesPageState extends State<VoiceProfilesPage> {
  final controller = FocusSessionController();

  @override
  void initState() {
    super.initState();
    controller.start();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sf;
    return Scaffold(
      appBar: AppBar(title: const Text('Detected Voices')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (_, __) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(t.containerPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(children: [
                  if (controller.loading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: LinearProgressIndicator(color: t.primary),
                    ),
                  ...controller.voices.map((voice) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => controller.selectVoice(voice.id),
                          child: GlassPanel(
                            active: voice.isSelected,
                            child: Row(children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(voice.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium),
                                    const SizedBox(height: 4),
                                    Text(_status(voice.status),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                                color: t.onSurfaceVariant)),
                                    const SizedBox(height: 12),
                                    AudioBars(
                                        values: voice.waveform,
                                        height: 36,
                                        dimmed: !voice.isSelected),
                                  ])),
                              Text(
                                  '${(voice.confidence * 100).toStringAsFixed(0)}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(color: t.primary)),
                            ]),
                          ),
                        ),
                      )),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      LiveListeningPage.routeName,
                      arguments: controller,
                    ),
                    child: Text('Focus ${controller.selectedVoice.label}'),
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _status(VoiceStatus s) => switch (s) {
        VoiceStatus.speakingNow => 'Speaking now',
        VoiceStatus.nearby => 'Nearby',
        VoiceStatus.background => 'Background',
        VoiceStatus.noisy => 'Noisy',
        VoiceStatus.lost => 'Lost',
      };
}
