import 'package:flutter/material.dart';

import '../features/voice_selector/controller/focus_session_controller.dart';
import '../features/voice_selector/model/voice_line.dart';
import '../theme/sonicfocus_theme.dart';
import '../ui/components/audio_bars.dart';
import '../ui/components/glass_panel.dart';
import 'focus_mode_page.dart';

class LiveListeningPage extends StatefulWidget {
  const LiveListeningPage({super.key});
  static const routeName = '/live-listening';

  @override
  State<LiveListeningPage> createState() => _LiveListeningPageState();
}

class _LiveListeningPageState extends State<LiveListeningPage> {
  late FocusSessionController controller;
  bool initialized = false;
  bool ownsController = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    controller =
        routeArg is FocusSessionController ? routeArg : FocusSessionController()
          ..start();
    ownsController = routeArg is! FocusSessionController;
    initialized = true;
  }

  @override
  void dispose() {
    if (ownsController) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sf;
    return Scaffold(
      appBar: AppBar(title: const Text('Live Listening')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(t.containerPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassPanel(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 32),
                        active: true,
                        child: Column(children: [
                          Icon(Icons.hearing, color: t.primary, size: 44),
                          const SizedBox(height: 16),
                          Text(
                            'Live Analysis',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: t.primary, letterSpacing: 2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Listening to your environment...',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 24),
                          AudioBars(
                            values: controller.selectedVoice.waveform,
                            height: 112,
                          ),
                        ]),
                      ),
                      const SizedBox(height: 32),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Detected Voices',
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            Text(
                              '${controller.voices.length} Active Sources',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: t.onSurfaceVariant),
                            ),
                          ]),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 720;
                          final cards =
                              controller.voices.map((voice) => _VoiceSourceCard(
                                    voice: voice.copyWith(
                                        isSelected: voice.id ==
                                            controller.selectedVoice.id),
                                    onTap: () =>
                                        controller.selectVoice(voice.id),
                                  ));

                          if (!isWide) {
                            return Column(
                              children: cards
                                  .map(
                                    (card) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: card,
                                    ),
                                  )
                                  .toList(),
                            );
                          }

                          final cardList = cards.toList();
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < cardList.length; i++)
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right:
                                            i == cardList.length - 1 ? 0 : 12),
                                    child: cardList[i],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          FocusModePage.routeName,
                          arguments: controller,
                        ),
                        icon: const Icon(Icons.graphic_eq),
                        label: Text('Focus ${controller.selectedVoice.label}'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Isolation ready: ${controller.selectedVoice.label} optimized',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                                color:
                                    t.onSurfaceVariant.withValues(alpha: 0.7)),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceSourceCard extends StatelessWidget {
  const _VoiceSourceCard({
    required this.voice,
    required this.onTap,
  });

  final VoiceLine voice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sf;
    return InkWell(
      borderRadius: BorderRadius.circular(t.panelRadius),
      onTap: onTap,
      child: GlassPanel(
        active: voice.isSelected,
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    _status(voice.status),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: voice.isSelected
                              ? t.primary
                              : t.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(voice.label,
                      style: Theme.of(context).textTheme.headlineMedium),
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                '${(voice.confidence * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: voice.isSelected ? t.primary : t.onSurfaceVariant),
              ),
              Text(
                'Confidence',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: t.onSurfaceVariant.withValues(alpha: 0.6)),
              ),
            ]),
          ]),
          const SizedBox(height: 20),
          AudioBars(values: voice.waveform, dimmed: !voice.isSelected),
        ]),
      ),
    );
  }

  String _status(VoiceStatus s) => switch (s) {
        VoiceStatus.speakingNow => 'Speaking Now',
        VoiceStatus.nearby => 'Nearby',
        VoiceStatus.background => 'Background',
        VoiceStatus.noisy => 'Noisy',
        VoiceStatus.lost => 'Lost',
      };
}
