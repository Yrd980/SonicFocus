# AGENTS.md

## Project
SonicFocus is a Flutter UI MVP for an AI hearing-focus app with a mock WebSocket session backend. The current goal is a runnable prototype of the user flow:

1. Onboarding
2. Voice selection
3. Live listening
4. Focus mode

The MVP uses mock voice data, simulated waveform visuals, and mock backend session events. Do not treat it as a real microphone, DSP, or AI-model implementation.

## Tooling
- Use `bun` for JS/TS work.
- Use `uv` for Python work.
- Use Flutter/Dart tooling inside `sonicfocus_flutter`.
- Use Context7 for official library docs when checking API details.
- Do not add test code unless the user explicitly asks for tests.

## Commands
Run the backend from `sonicfocus_backend`:

```sh
uv sync
uv run uvicorn app.main:app --host 127.0.0.1 --port 8000
uv run python -m compileall app
```

Run Flutter from `sonicfocus_flutter`:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib
flutter analyze
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 0
```

If `flutter` is not on PATH on this machine, use:

```sh
C:\Users\Yrd98\scoop\apps\flutter\3.44.1\bin\flutter.bat
C:\Users\Yrd98\scoop\apps\flutter\3.44.1\bin\dart.bat
```

## Source Map
- Flutter app: `sonicfocus_flutter/lib`
- App routes: `sonicfocus_flutter/lib/main.dart`
- Theme tokens: `sonicfocus_flutter/lib/theme/sonicfocus_theme.dart`
- Glass panel component: `sonicfocus_flutter/lib/ui/components/glass_panel.dart`
- Audio bars component: `sonicfocus_flutter/lib/ui/components/audio_bars.dart`
- Voice/session feature: `sonicfocus_flutter/lib/features/voice_selector`
  - Voice model: `model/voice_line.dart`
  - Session model: `model/focus_session.dart`
  - WebSocket client: `data/sonic_focus_session_client.dart`
  - Session controller: `controller/focus_session_controller.dart`
- Mock backend: `sonicfocus_backend/app`
  - FastAPI entry: `sonicfocus_backend/app/main.py`
  - Backend models: `sonicfocus_backend/app/models.py`
  - In-memory store: `sonicfocus_backend/app/session_store.py`
  - Event simulator: `sonicfocus_backend/app/simulator.py`
- Stitch source designs: `stitch_sonicfocus_ai_hearing_app`
- Parity checklist: `sonicfocus_flutter/docs/stitch_parity_checklist.md`

## Current Backend Contract
The current backend is WebSocket-only except for `GET /health`.

```txt
GET /health
WS  /ws/v1/sessions/{session_id}/events
```

Flutter creates a local mock session id and connects to `ws://127.0.0.1:8000/ws/v1/sessions/{session_id}/events`. The backend calls `store.ensure(session_id)` and creates that mock session on demand.

Server events:

- `voice_snapshot`
- `waveform_update`
- `voice_update`
- `processing_metrics`
- `session_state`

Client commands:

- `select_voice`
- `settings_update`
- `state_update`
- `stop_session`

## Implementation Rules
- Keep changes surgical and tied to the requested MVP behavior.
- Preserve the existing Flutter style and Material 3 setup.
- Prefer simple Flutter widgets over new dependencies.
- Keep the UI responsive with `SafeArea`, `SingleChildScrollView`, `LayoutBuilder`, and constrained content widths.
- Reuse `SonicFocusTokens`, `GlassPanel`, and `AudioBars` before creating new styling primitives.
- Keep fallback mock voice data centralized in `demoVoiceLines`.
- Use `FocusSessionController` for session state and route handoff between Voice Profiles, Live Listening, and Focus Mode.
- Keep the current backend mock-only unless explicitly asked to add real audio capture, DSP, backend persistence, or model integration.
- Do not replace the WebSocket-only protocol with REST unless the user explicitly asks for REST endpoints.

## Design Notes
- Visual direction: premium dark audio workstation, glassmorphism, blue/purple neon accents.
- Active controls need a visible border and glow.
- Spacing should stay on 8px multiples where practical.
- The current parity gap is screenshot/pixel comparison against the Stitch HTML.
