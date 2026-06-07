# SonicFocus

SonicFocus is a Flutter UI MVP for an AI hearing-focus app. It demonstrates how a user can detect nearby voices, choose one target voice, and enter a focus session where the target voice is enhanced while background sound is reduced.

This repository currently focuses on the product prototype, Stitch-to-Flutter visual parity, and a mock session backend. It does not include real microphone capture, DSP, or AI model integration.

## MVP Flow

- `Onboarding`: brand entry point with the SonicFocus promise.
- `Voice Profiles`: mock detected voices with status, confidence, selection state, and waveform previews.
- `Live Listening`: live-analysis screen with detected voice cards and a selected target voice.
- `Focus Mode`: focused listening session with waveform visualization, focus strength, noise reduction, feature toggles, pause, and stop controls.

## Tech Stack

- Flutter
- Dart
- Material 3
- `web_socket_channel`
- FastAPI
- Python
- uv
- Mock WebSocket session data

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
sonicfocus_backend/
  app/
    main.py
    models.py
    session_store.py
    simulator.py
  pyproject.toml
stitch_sonicfocus_ai_hearing_app/
  onboarding_sonicfocus/
  voice_profiles_sonicfocus/
  live_listening_sonicfocus/
  focus_mode_sonicfocus/
  sonicfocus/DESIGN.md
```

## Run Locally

Start the mock backend from `sonicfocus_backend`:

```sh
uv sync
uv run uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Start the Flutter web app from `sonicfocus_flutter`:

```sh
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 0
```

Flutter prints the local URL after the web server starts.

The Flutter client defaults to `ws://127.0.0.1:8000` for mock session events.

## Check The App

```sh
dart format --output=none --set-exit-if-changed lib
flutter analyze
```

Backend check:

```sh
uv run python -m compileall app
```

Current verification status:

- `flutter analyze`: passing
- WebSocket-only mock backend smoke checked
- Stitch page parity checklist: all major page implementations complete
- Pixel-level screenshot comparison: still pending

## MVP Boundary

Included:

- Complete mock UI flow from onboarding to focus session
- Mock WebSocket session backend
- Shared SonicFocus theme tokens
- Reusable glass panel component
- Reusable audio bar visualization
- Mock voice selection and session-controller handoff
- Responsive mobile/desktop layout structure

Not included yet:

- Real microphone permission or capture
- Real-time audio processing
- Speaker diarization or voice clustering model
- Voice profile enrollment storage
- Production backend sync
- Automated screenshot diffing

## Mock Backend Protocol

The current backend is WebSocket-only except for `/health`.

```txt
GET /health
WS  /ws/v1/sessions/{session_id}/events
```

The Flutter client creates a local mock session id and opens the WebSocket. The backend creates that session on demand with mock voice sources.

Server events include:

- `voice_snapshot`
- `waveform_update`
- `voice_update`
- `processing_metrics`
- `session_state`

Client commands include:

- `select_voice`
- `settings_update`
- `state_update`
- `stop_session`

## Design Source

The visual source of truth is `stitch_sonicfocus_ai_hearing_app/sonicfocus/DESIGN.md` and the four Stitch HTML pages. Flutter parity progress is tracked in `sonicfocus_flutter/docs/stitch_parity_checklist.md`.
