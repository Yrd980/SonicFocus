# AGENTS.md

## Project
SonicFocus is a Flutter UI MVP for an AI hearing-focus app. The current goal is a runnable prototype of the user flow:

1. Onboarding
2. Voice selection
3. Live listening
4. Focus mode

The MVP uses mock voice data and simulated waveform visuals. Do not treat it as a real microphone, DSP, or AI-model implementation.

## Tooling
- Use `bun` for JS/TS work.
- Use `uv` for Python work.
- Use Flutter/Dart tooling inside `sonicfocus_flutter`.
- Use Context7 for official library docs when checking API details.
- Do not add test code unless the user explicitly asks for tests.

## Commands
Run from `sonicfocus_flutter`:

```sh
flutter pub get
dart format lib
flutter analyze
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 0
```

## Source Map
- Flutter app: `sonicfocus_flutter/lib`
- App routes: `sonicfocus_flutter/lib/main.dart`
- Theme tokens: `sonicfocus_flutter/lib/theme/sonicfocus_theme.dart`
- Glass panel component: `sonicfocus_flutter/lib/ui/components/glass_panel.dart`
- Audio bars component: `sonicfocus_flutter/lib/ui/components/audio_bars.dart`
- Voice mock model/controller: `sonicfocus_flutter/lib/features/voice_selector`
- Stitch source designs: `stitch_sonicfocus_ai_hearing_app`
- Parity checklist: `sonicfocus_flutter/docs/stitch_parity_checklist.md`

## Implementation Rules
- Keep changes surgical and tied to the requested MVP behavior.
- Preserve the existing Flutter style and Material 3 setup.
- Prefer simple Flutter widgets over new dependencies.
- Keep the UI responsive with `SafeArea`, `SingleChildScrollView`, `LayoutBuilder`, and constrained content widths.
- Reuse `SonicFocusTokens`, `GlassPanel`, and `AudioBars` before creating new styling primitives.
- Keep mock data centralized in `demoVoiceLines` unless the app grows a real state layer.
- Pass selected voice state through route arguments for the current MVP.
- Do not add real audio capture, backend calls, or model integration without a separate explicit request.

## Design Notes
- Visual direction: premium dark audio workstation, glassmorphism, blue/purple neon accents.
- Active controls need a visible border and glow.
- Spacing should stay on 8px multiples where practical.
- The current parity gap is screenshot/pixel comparison against the Stitch HTML.
