import 'voice_line.dart';

const _unset = Object();

enum FocusSessionState { created, listening, focused, paused, stopped }

class FocusSettings {
  const FocusSettings({
    this.focusStrength = 1,
    this.voiceEnhance = true,
    this.backgroundReduce = true,
    this.safeAwareness = false,
  });

  final int focusStrength;
  final bool voiceEnhance;
  final bool backgroundReduce;
  final bool safeAwareness;

  factory FocusSettings.fromJson(Map<String, dynamic> json) {
    return FocusSettings(
      focusStrength: ((json['focusStrength'] as num?)?.round() ?? 1).clamp(
        0,
        2,
      ),
      voiceEnhance: json['voiceEnhance'] as bool? ?? true,
      backgroundReduce: json['backgroundReduce'] as bool? ?? true,
      safeAwareness: json['safeAwareness'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'focusStrength': focusStrength,
      'voiceEnhance': voiceEnhance,
      'backgroundReduce': backgroundReduce,
      'safeAwareness': safeAwareness,
    };
  }

  FocusSettings copyWith({
    int? focusStrength,
    bool? voiceEnhance,
    bool? backgroundReduce,
    bool? safeAwareness,
  }) {
    return FocusSettings(
      focusStrength: (focusStrength ?? this.focusStrength).clamp(0, 2),
      voiceEnhance: voiceEnhance ?? this.voiceEnhance,
      backgroundReduce: backgroundReduce ?? this.backgroundReduce,
      safeAwareness: safeAwareness ?? this.safeAwareness,
    );
  }
}

class SessionMetrics {
  const SessionMetrics({
    this.latencyMs = 0,
    this.suppressionDb = 0,
    this.targetSnrDb = 0,
  });

  final int latencyMs;
  final int suppressionDb;
  final int targetSnrDb;

  factory SessionMetrics.fromJson(Map<String, dynamic> json) {
    return SessionMetrics(
      latencyMs: (json['latencyMs'] as num?)?.round() ?? 0,
      suppressionDb: (json['suppressionDb'] as num?)?.round() ?? 0,
      targetSnrDb: (json['targetSnrDb'] as num?)?.round() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latencyMs': latencyMs,
      'suppressionDb': suppressionDb,
      'targetSnrDb': targetSnrDb,
    };
  }
}

class FocusSession {
  const FocusSession({
    required this.id,
    required this.state,
    this.selectedSourceId,
    this.settings = const FocusSettings(),
    this.metrics = const SessionMetrics(),
    this.voices = const [],
  });

  final String id;
  final FocusSessionState state;
  final String? selectedSourceId;
  final FocusSettings settings;
  final SessionMetrics metrics;
  final List<VoiceLine> voices;

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      state: focusSessionStateFromJson(json['state'] as String?),
      selectedSourceId: json['selectedSourceId'] as String?,
      settings: FocusSettings.fromJson(
        json['settings'] as Map<String, dynamic>? ?? const {},
      ),
      metrics: SessionMetrics.fromJson(
        json['metrics'] as Map<String, dynamic>? ?? const {},
      ),
      voices: (json['voices'] as List? ?? const [])
          .map((voice) => VoiceLine.fromJson(
                Map<String, dynamic>.from(voice as Map),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state.toJson(),
      'selectedSourceId': selectedSourceId,
      'settings': settings.toJson(),
      'metrics': metrics.toJson(),
      'voices': voices.map((voice) => voice.toJson()).toList(),
    };
  }

  FocusSession copyWith({
    FocusSessionState? state,
    Object? selectedSourceId = _unset,
    FocusSettings? settings,
    SessionMetrics? metrics,
    List<VoiceLine>? voices,
  }) {
    return FocusSession(
      id: id,
      state: state ?? this.state,
      selectedSourceId: selectedSourceId == _unset
          ? this.selectedSourceId
          : selectedSourceId as String?,
      settings: settings ?? this.settings,
      metrics: metrics ?? this.metrics,
      voices: voices ?? this.voices,
    );
  }
}

extension FocusSessionStateJson on FocusSessionState {
  String toJson() {
    return switch (this) {
      FocusSessionState.created => 'created',
      FocusSessionState.listening => 'listening',
      FocusSessionState.focused => 'focused',
      FocusSessionState.paused => 'paused',
      FocusSessionState.stopped => 'stopped',
    };
  }
}

FocusSessionState focusSessionStateFromJson(String? value) {
  return switch (value) {
    'created' => FocusSessionState.created,
    'listening' => FocusSessionState.listening,
    'focused' => FocusSessionState.focused,
    'paused' => FocusSessionState.paused,
    'stopped' => FocusSessionState.stopped,
    _ => FocusSessionState.created,
  };
}
