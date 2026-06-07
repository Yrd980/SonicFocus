import 'package:flutter/material.dart';

import '../features/voice_selector/controller/focus_session_controller.dart';
import '../features/voice_selector/model/focus_session.dart';
import '../theme/sonicfocus_theme.dart';
import '../ui/components/audio_bars.dart';
import '../ui/components/glass_panel.dart';

class FocusModePage extends StatefulWidget {
  const FocusModePage({super.key});
  static const routeName = '/focus-mode';

  @override
  State<FocusModePage> createState() => _FocusModePageState();
}

class _FocusModePageState extends State<FocusModePage> {
  bool initialized = false;
  bool ownsController = false;
  late FocusSessionController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    controller = routeArg is FocusSessionController
        ? routeArg
        : FocusSessionController();
    ownsController = routeArg is! FocusSessionController;
    controller.enterFocusMode();
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
      appBar: AppBar(title: const Text('Focus Mode')),
      bottomNavigationBar: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final paused = controller.state == FocusSessionState.paused;
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: t.backgroundOverlay.withValues(alpha: 0.88),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.updateState(
                      paused
                          ? FocusSessionState.focused
                          : FocusSessionState.paused,
                    ),
                    icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                    label: Text(paused ? 'Resume' : 'Pause'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF93000A),
                      foregroundColor: const Color(0xFFFFDAD6),
                    ),
                    onPressed: () async {
                      await controller.stop();
                      if (!context.mounted) return;
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Listening'),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final settings = controller.settings;
          final strength = settings.focusStrength.toDouble();
          final label = ['Low', 'Medium', 'High'][strength.toInt()];
          final paused = controller.state == FocusSessionState.paused;
          final voice = controller.selectedVoice;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                t.containerPadding,
                t.containerPadding,
                t.containerPadding,
                120,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          paused ? 'Session Paused' : 'Active Session',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: t.primary, letterSpacing: 2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Focused on ${voice.label}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 32),
                        GlassPanel(
                          active: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 36),
                          child: Column(children: [
                            AudioBars(
                              values:
                                  _sessionWaveform(voice.waveform, strength),
                              height: 180,
                              dimmed: paused,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              paused
                                  ? 'Audio processing paused'
                                  : 'Target voice enhanced in real time',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: t.onSurfaceVariant),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 720;
                            final cards = [
                              _FocusStrengthCard(
                                label: label,
                                strength: strength,
                                onChanged: (value) => controller.updateSettings(
                                  settings.copyWith(
                                      focusStrength: value.round()),
                                ),
                              ),
                              _NoiseReductionCard(
                                strength: strength,
                                suppressionDb: controller.metrics.suppressionDb,
                              ),
                            ];

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

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0; i < cards.length; i++)
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right:
                                              i == cards.length - 1 ? 0 : 12),
                                      child: cards[i],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 720;
                            final controls = [
                              _ToggleControl(
                                label: 'Voice Enhance',
                                icon: Icons.record_voice_over,
                                value: settings.voiceEnhance,
                                onTap: () => controller.updateSettings(
                                  settings.copyWith(
                                    voiceEnhance: !settings.voiceEnhance,
                                  ),
                                ),
                              ),
                              _ToggleControl(
                                label: 'Background Reduce',
                                icon: Icons.filter_vintage,
                                value: settings.backgroundReduce,
                                onTap: () => controller.updateSettings(
                                  settings.copyWith(
                                    backgroundReduce:
                                        !settings.backgroundReduce,
                                  ),
                                ),
                              ),
                              _ToggleControl(
                                label: 'Safe Awareness',
                                icon: Icons.hearing,
                                value: settings.safeAwareness,
                                onTap: () => controller.updateSettings(
                                  settings.copyWith(
                                    safeAwareness: !settings.safeAwareness,
                                  ),
                                ),
                              ),
                            ];

                            if (!isWide) {
                              return Column(
                                children: controls
                                    .map(
                                      (control) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: control,
                                      ),
                                    )
                                    .toList(),
                              );
                            }

                            return Row(
                              children: [
                                for (var i = 0; i < controls.length; i++)
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: i == controls.length - 1
                                              ? 0
                                              : 12),
                                      child: controls[i],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<int> _sessionWaveform(List<int> waveform, double strength) {
    final boost = strength.toInt();
    final base =
        waveform.isEmpty ? const [3, 7, 5, 8, 4, 6, 7, 2, 5, 8] : waveform;
    return base.map((value) => (value + boost).clamp(1, 8).round()).toList();
  }
}

class _FocusStrengthCard extends StatelessWidget {
  const _FocusStrengthCard({
    required this.label,
    required this.strength,
    required this.onChanged,
  });

  final String label;
  final double strength;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.sf;
    return GlassPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Focus Strength',
              style: Theme.of(context).textTheme.labelMedium),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: t.primary)),
        ]),
        const SizedBox(height: 16),
        Slider(
            value: strength,
            divisions: 2,
            min: 0,
            max: 2,
            onChanged: onChanged),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Low',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: t.onSurfaceVariant)),
          Text('Med',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: t.onSurfaceVariant)),
          Text('High',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: t.onSurfaceVariant)),
        ]),
      ]),
    );
  }
}

class _NoiseReductionCard extends StatelessWidget {
  const _NoiseReductionCard({
    required this.strength,
    required this.suppressionDb,
  });

  final double strength;
  final int suppressionDb;

  @override
  Widget build(BuildContext context) {
    final t = context.sf;
    final suppressDb =
        suppressionDb > 0 ? suppressionDb : 18 + strength.toInt() * 6;
    return GlassPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Noise Reduction',
              style: Theme.of(context).textTheme.labelMedium),
          Icon(Icons.verified, color: t.tertiary),
        ]),
        const SizedBox(height: 20),
        AudioBars(
          values: const [8, 7, 8, 6, 5, 3, 2],
          color: t.tertiary,
          height: 56,
          dimmed: false,
        ),
        const SizedBox(height: 12),
        Text(
          '-${suppressDb}dB Active Suppress',
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: t.tertiary),
        ),
      ]),
    );
  }
}

class _ToggleControl extends StatelessWidget {
  const _ToggleControl({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sf;
    return InkWell(
      borderRadius: BorderRadius.circular(t.panelRadius),
      onTap: onTap,
      child: GlassPanel(
        active: value,
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (value ? t.primary : t.onSurfaceVariant)
                  .withValues(alpha: value ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(t.controlRadius),
            ),
            child: Icon(icon, color: value ? t.primary : t.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: value ? t.onSurface : t.onSurfaceVariant),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: value ? t.primary : Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              boxShadow:
                  value ? [BoxShadow(color: t.primary, blurRadius: 8)] : null,
            ),
          ),
        ]),
      ),
    );
  }
}
