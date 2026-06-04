# SonicFocus

SonicFocus is a Flutter UI MVP for an AI hearing-focus app. It demonstrates how a user can detect nearby voices, choose one target voice, and enter a focus session where the target voice is enhanced while background sound is reduced.

This repository currently focuses on the product prototype and Stitch-to-Flutter visual parity. It does not include real microphone capture, DSP, backend services, or AI model integration.

## MVP Flow

- `Onboarding`: brand entry point with the SonicFocus promise.
- `Voice Profiles`: mock detected voices with status, confidence, selection state, and waveform previews.
- `Live Listening`: live-analysis screen with detected voice cards and a selected target voice.
- `Focus Mode`: focused listening session with waveform visualization, focus strength, noise reduction, feature toggles, pause, and stop controls.

## Tech Stack

- Flutter
- Dart
- Material 3
- Local mock data

## Project Layout

```txt
sonicfocus_flutter/
  lib/
    main.dart
    features/voice_selector/
    pages/
    theme/
    ui/components/
  docs/stitch_parity_checklist.md
stitch_sonicfocus_ai_hearing_app/
  onboarding_sonicfocus/
  voice_profiles_sonicfocus/
  live_listening_sonicfocus/
  focus_mode_sonicfocus/
  sonicfocus/DESIGN.md
```

## Run Locally

Run these commands from `sonicfocus_flutter`:

```sh
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 0
```

Flutter prints the local URL after the web server starts.

## Check The App

```sh
dart format lib
flutter analyze
```

Current verification status:

- `flutter analyze`: passing
- Stitch page parity checklist: all major page implementations complete
- Pixel-level screenshot comparison: still pending

## MVP Boundary

Included:

- Complete mock UI flow from onboarding to focus session
- Shared SonicFocus theme tokens
- Reusable glass panel component
- Reusable audio bar visualization
- Mock voice selection and route-state handoff
- Responsive mobile/desktop layout structure

Not included yet:

- Real microphone permission or capture
- Real-time audio processing
- Speaker diarization or voice clustering model
- Voice profile enrollment storage
- Backend sync
- Automated screenshot diffing

## Design Source

The visual source of truth is `stitch_sonicfocus_ai_hearing_app/sonicfocus/DESIGN.md` and the four Stitch HTML pages. Flutter parity progress is tracked in `sonicfocus_flutter/docs/stitch_parity_checklist.md`.
