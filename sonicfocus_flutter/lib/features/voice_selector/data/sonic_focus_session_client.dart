import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../controller/voice_selector_controller.dart';
import '../model/focus_session.dart';
import '../model/voice_line.dart';

abstract class SonicFocusSessionClient {
  Future<FocusSession> createSession();

  Future<FocusSession> selectVoice(String sessionId, String sourceId);

  Future<FocusSession> updateSettings(
    String sessionId,
    FocusSettings settings,
  );

  Future<FocusSession> updateState(
    String sessionId,
    FocusSessionState state,
  );

  Future<void> stopSession(String sessionId);

  Stream<SessionEvent> watchSession(String sessionId);
}

class SessionEvent {
  const SessionEvent({
    required this.type,
    this.session,
    this.voice,
    this.voices,
    this.sourceId,
    this.waveformBins,
    this.metrics,
    this.state,
    this.selectedSourceId,
  });

  final String type;
  final FocusSession? session;
  final VoiceLine? voice;
  final List<VoiceLine>? voices;
  final String? sourceId;
  final List<int>? waveformBins;
  final SessionMetrics? metrics;
  final FocusSessionState? state;
  final String? selectedSourceId;

  factory SessionEvent.fromJson(Map<String, dynamic> json) {
    return SessionEvent(
      type: json['type'] as String,
      session: json['session'] == null
          ? null
          : FocusSession.fromJson(json['session'] as Map<String, dynamic>),
      voice: json['voice'] == null
          ? null
          : VoiceLine.fromJson(
              Map<String, dynamic>.from(json['voice'] as Map),
            ),
      voices: (json['voices'] as List?)
          ?.map((voice) => VoiceLine.fromJson(
                Map<String, dynamic>.from(voice as Map),
              ))
          .toList(),
      sourceId: json['sourceId'] as String?,
      waveformBins: ((json['waveformBins'] ?? json['bins']) as List?)
          ?.map((value) => (value as num).round())
          .toList(),
      metrics: json['metrics'] == null
          ? null
          : SessionMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      state: json['state'] == null
          ? null
          : focusSessionStateFromJson(json['state'] as String?),
      selectedSourceId: json['selectedSourceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (session != null) 'session': session!.toJson(),
      if (voice != null) 'voice': voice!.toJson(),
      if (voices != null) 'voices': voices!.map((v) => v.toJson()).toList(),
      if (sourceId != null) 'sourceId': sourceId,
      if (waveformBins != null) 'waveformBins': waveformBins,
      if (metrics != null) 'metrics': metrics!.toJson(),
      if (state != null) 'state': state!.toJson(),
      if (selectedSourceId != null) 'selectedSourceId': selectedSourceId,
    };
  }
}

class WebSocketSonicFocusSessionClient implements SonicFocusSessionClient {
  WebSocketSonicFocusSessionClient({
    this.baseUrl = 'ws://127.0.0.1:8000',
  });

  final String baseUrl;

  FocusSession? _session;
  final Map<String, WebSocketChannel> _channels = {};
  final Map<String, StreamController<SessionEvent>> _streams = {};

  @override
  Future<FocusSession> createSession() async {
    final session = FocusSession(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      state: FocusSessionState.listening,
      selectedSourceId: demoVoiceLines.first.id,
      voices: demoVoiceLines,
    );
    _session = session;
    return session;
  }

  @override
  Future<FocusSession> selectVoice(String sessionId, String sourceId) async {
    final session = _requireSession(sessionId);
    final next = session.copyWith(
      selectedSourceId: sourceId,
      voices: _markSelected(session.voices, sourceId),
    );
    _session = next;
    _send(sessionId, {'type': 'select_voice', 'sourceId': sourceId});
    return next;
  }

  @override
  Future<FocusSession> updateSettings(
    String sessionId,
    FocusSettings settings,
  ) async {
    final next = _requireSession(sessionId).copyWith(settings: settings);
    _session = next;
    _send(
        sessionId, {'type': 'settings_update', 'settings': settings.toJson()});
    return next;
  }

  @override
  Future<FocusSession> updateState(
    String sessionId,
    FocusSessionState state,
  ) async {
    final next = _requireSession(sessionId).copyWith(state: state);
    _session = next;
    _send(sessionId, {'type': 'state_update', 'state': state.toJson()});
    return next;
  }

  @override
  Future<void> stopSession(String sessionId) async {
    _send(sessionId, {'type': 'stop_session'});
    await _channels.remove(sessionId)?.sink.close();
    await _streams.remove(sessionId)?.close();
  }

  @override
  Stream<SessionEvent> watchSession(String sessionId) {
    return _ensureStream(sessionId).stream;
  }

  StreamController<SessionEvent> _ensureStream(String sessionId) {
    final existing = _streams[sessionId];
    if (existing != null) return existing;

    final controller = StreamController<SessionEvent>.broadcast();
    final channel = WebSocketChannel.connect(
      _webSocketUri('/ws/v1/sessions/$sessionId/events'),
    );
    _channels[sessionId] = channel;
    _streams[sessionId] = controller;

    channel.stream.listen(
      (message) {
        final json = jsonDecode(message as String) as Map<String, dynamic>;
        final event = SessionEvent.fromJson(json);
        _applyEvent(event);
        controller.add(event);
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    return controller;
  }

  void _send(String sessionId, Map<String, dynamic> message) {
    _ensureStream(sessionId);
    _channels[sessionId]?.sink.add(jsonEncode(message));
  }

  Uri _webSocketUri(String path) {
    final base = Uri.parse(baseUrl);
    final scheme = switch (base.scheme) {
      'https' => 'wss',
      'http' => 'ws',
      _ => base.scheme,
    };
    return base.replace(
      scheme: scheme,
      path: path,
    );
  }

  FocusSession _requireSession(String sessionId) {
    return _session ??
        FocusSession(
          id: sessionId,
          state: FocusSessionState.listening,
          selectedSourceId: demoVoiceLines.first.id,
          voices: demoVoiceLines,
        );
  }

  void _applyEvent(SessionEvent event) {
    final session = _session;
    if (event.session != null) {
      _session = event.session;
      return;
    }
    if (session == null) return;

    final voices = event.voices;
    if (voices != null) {
      _session = session.copyWith(voices: voices);
      return;
    }

    final voice = event.voice;
    if (voice != null) {
      _session = session.copyWith(
        voices: _replaceVoice(session.voices, voice),
      );
      return;
    }

    final sourceId = event.sourceId;
    final waveformBins = event.waveformBins;
    if (sourceId != null && waveformBins != null) {
      _session = session.copyWith(
        voices: session.voices
            .map(
              (voice) => voice.id == sourceId
                  ? voice.copyWith(waveform: waveformBins)
                  : voice,
            )
            .toList(),
      );
      return;
    }

    final metrics = event.metrics;
    if (metrics != null) {
      _session = session.copyWith(metrics: metrics);
      return;
    }

    final state = event.state;
    if (state != null) {
      _session = session.copyWith(
        state: state,
        selectedSourceId: event.selectedSourceId,
      );
    }
  }
}

class MockSonicFocusSessionClient implements SonicFocusSessionClient {
  MockSonicFocusSessionClient();

  FocusSession? _session;

  @override
  Future<FocusSession> createSession() async {
    final voices = demoVoiceLines.toList();
    _session = FocusSession(
      id: 'demo_session',
      state: FocusSessionState.listening,
      selectedSourceId: voices.first.id,
      voices: voices,
    );
    return _session!;
  }

  Future<FocusSession> _getSession(String sessionId) async {
    return _session ?? await createSession();
  }

  @override
  Future<FocusSession> selectVoice(String sessionId, String sourceId) async {
    final session = await _getSession(sessionId);
    final voices = _markSelected(session.voices, sourceId);
    _session = session.copyWith(
      selectedSourceId: sourceId,
      voices: voices,
    );
    return _session!;
  }

  @override
  Future<FocusSession> updateSettings(
    String sessionId,
    FocusSettings settings,
  ) async {
    final session = await _getSession(sessionId);
    _session = session.copyWith(settings: settings);
    return _session!;
  }

  @override
  Future<FocusSession> updateState(
    String sessionId,
    FocusSessionState state,
  ) async {
    final session = await _getSession(sessionId);
    _session = session.copyWith(state: state);
    return _session!;
  }

  @override
  Future<void> stopSession(String sessionId) async {
    final session = await _getSession(sessionId);
    _session = session.copyWith(state: FocusSessionState.stopped);
  }

  @override
  Stream<SessionEvent> watchSession(String sessionId) async* {
    final session = await _getSession(sessionId);
    yield SessionEvent(type: 'voice_snapshot', voices: session.voices);
    yield SessionEvent(type: 'session_state', session: session);
  }
}

List<VoiceLine> _markSelected(List<VoiceLine> voices, String sourceId) {
  return voices
      .map((voice) => voice.copyWith(isSelected: voice.id == sourceId))
      .toList();
}

List<VoiceLine> _replaceVoice(List<VoiceLine> voices, VoiceLine nextVoice) {
  return voices
      .map((voice) => voice.id == nextVoice.id ? nextVoice : voice)
      .toList();
}
