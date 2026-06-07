import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/sonic_focus_session_client.dart';
import '../model/focus_session.dart';
import '../model/voice_line.dart';
import 'voice_selector_controller.dart';

class FocusSessionController extends ChangeNotifier {
  FocusSessionController({
    SonicFocusSessionClient? client,
  }) : _client = client ?? WebSocketSonicFocusSessionClient();

  final SonicFocusSessionClient _client;
  StreamSubscription<SessionEvent>? _events;
  Future<void>? _startFuture;
  FocusSession? _session;
  bool _loading = false;
  String? _error;
  bool _disposed = false;

  FocusSession? get session => _session;
  bool get loading => _loading;
  String? get error => _error;
  List<VoiceLine> get voices => _session?.voices ?? demoVoiceLines;
  FocusSettings get settings => _session?.settings ?? const FocusSettings();
  SessionMetrics get metrics => _session?.metrics ?? const SessionMetrics();
  FocusSessionState get state => _session?.state ?? FocusSessionState.listening;

  VoiceLine get selectedVoice {
    final voiceList = voices;
    final selectedSourceId = _session?.selectedSourceId;
    final selectedById =
        voiceList.where((voice) => voice.id == selectedSourceId);
    if (selectedById.isNotEmpty) return selectedById.first;

    return voiceList.firstWhere(
      (voice) => voice.isSelected,
      orElse: () => demoVoiceLines.first,
    );
  }

  Future<void> start() async {
    if (_session != null) return;
    final existingStart = _startFuture;
    if (existingStart != null) {
      await existingStart;
      return;
    }

    _startFuture = _createSession();
    try {
      await _startFuture;
    } finally {
      _startFuture = null;
    }
  }

  Future<void> enterFocusMode() async {
    await start();
    await updateState(FocusSessionState.focused);
  }

  Future<void> _createSession() async {
    if (_disposed) return;
    _loading = true;
    _error = null;
    _notify();

    try {
      _session = await _client.createSession();
      if (_disposed) return;
      _watch(_session!.id);
    } catch (error) {
      if (_disposed) return;
      _error = error.toString();
      _session = FocusSession(
        id: 'local_fallback',
        state: FocusSessionState.listening,
        selectedSourceId: demoVoiceLines.first.id,
        voices: demoVoiceLines,
      );
    } finally {
      if (!_disposed) {
        _loading = false;
        _notify();
      }
    }
  }

  Future<void> selectVoice(String sourceId) async {
    await start();
    _applySession(
      _requireSession().copyWith(
        selectedSourceId: sourceId,
        voices: _markSelected(sourceId),
      ),
    );

    try {
      _applySession(await _client.selectVoice(_requireSession().id, sourceId));
    } catch (error) {
      if (_disposed) return;
      _error = error.toString();
      _notify();
    }
  }

  Future<void> updateSettings(FocusSettings settings) async {
    await start();
    _applySession(_requireSession().copyWith(settings: settings));
    try {
      _applySession(
          await _client.updateSettings(_requireSession().id, settings));
    } catch (error) {
      if (_disposed) return;
      _error = error.toString();
      _notify();
    }
  }

  Future<void> updateState(FocusSessionState state) async {
    await start();
    _applySession(_requireSession().copyWith(state: state));
    try {
      _applySession(await _client.updateState(_requireSession().id, state));
    } catch (error) {
      if (_disposed) return;
      _error = error.toString();
      _notify();
    }
  }

  Future<void> stop() async {
    final session = _session;
    if (session == null) return;
    await _events?.cancel();
    _events = null;
    try {
      await _client.stopSession(session.id);
    } catch (error) {
      if (_disposed) return;
      _error = error.toString();
    }
  }

  void _watch(String sessionId) {
    _events?.cancel();
    _events = _client.watchSession(sessionId).listen(
      _applyEvent,
      onError: (Object error) {
        if (_disposed) return;
        _error = error.toString();
        _notify();
      },
    );
  }

  void _applyEvent(SessionEvent event) {
    switch (event.type) {
      case 'voice_snapshot':
        final voices = event.voices;
        if (voices != null) {
          _applySession(_requireSession().copyWith(voices: voices));
        }
        break;
      case 'voice_update':
        final voice = event.voice;
        if (voice != null) {
          _replaceVoice(voice);
        }
        break;
      case 'waveform_update':
        final sourceId = event.sourceId;
        final waveform = event.waveformBins;
        if (sourceId != null && waveform != null) {
          _replaceVoiceById(
            sourceId,
            (voice) => voice.copyWith(waveform: waveform),
          );
        }
        break;
      case 'processing_metrics':
        final metrics = event.metrics;
        if (metrics != null) {
          _applySession(_requireSession().copyWith(metrics: metrics));
        }
        break;
      case 'session_state':
        final session = event.session;
        if (session != null) {
          _applySession(session);
          break;
        }
        final state = event.state;
        _applySession(
          _requireSession().copyWith(
            state: state,
            selectedSourceId: event.selectedSourceId,
          ),
        );
        break;
    }
  }

  FocusSession _requireSession() {
    final session = _session;
    if (session != null) return session;
    return FocusSession(
      id: 'local_fallback',
      state: FocusSessionState.listening,
      selectedSourceId: demoVoiceLines.first.id,
      voices: demoVoiceLines,
    );
  }

  List<VoiceLine> _markSelected(String sourceId) {
    return voices
        .map((voice) => voice.copyWith(isSelected: voice.id == sourceId))
        .toList();
  }

  void _replaceVoice(VoiceLine voice) {
    _replaceVoiceById(voice.id, (_) => voice);
  }

  void _replaceVoiceById(
    String sourceId,
    VoiceLine Function(VoiceLine voice) update,
  ) {
    final session = _requireSession();
    final nextVoices = session.voices
        .map((voice) => voice.id == sourceId ? update(voice) : voice)
        .toList();
    _applySession(session.copyWith(voices: nextVoices));
  }

  void _applySession(FocusSession session) {
    if (_disposed) return;
    _session = session.copyWith(
      voices: _voicesWithSelected(session.selectedSourceId, session.voices),
    );
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _events?.cancel();
    super.dispose();
  }
}

List<VoiceLine> _voicesWithSelected(
  String? selectedSourceId,
  List<VoiceLine> voices,
) {
  if (selectedSourceId == null) return voices;
  return voices
      .map((voice) => voice.copyWith(isSelected: voice.id == selectedSourceId))
      .toList();
}
