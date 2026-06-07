enum VoiceStatus { speakingNow, nearby, background, noisy, lost }

class VoiceLine {
  const VoiceLine({
    required this.id,
    required this.label,
    required this.status,
    required this.confidence,
    required this.isSelected,
    this.waveform = const [4, 7, 3, 8, 5, 7, 2],
  });

  final String id;
  final String label;
  final VoiceStatus status;
  final double confidence;
  final bool isSelected;
  final List<int> waveform;

  factory VoiceLine.fromJson(Map<String, dynamic> json) {
    return VoiceLine(
      id: json['id'] as String,
      label: json['label'] as String,
      status: voiceStatusFromJson(json['status'] as String?),
      confidence: (json['confidence'] as num).toDouble(),
      isSelected: (json['selected'] ?? json['isSelected'] ?? false) as bool,
      waveform: _intListFromJson(json['waveformBins'] ?? json['waveform']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'status': status.toJson(),
      'confidence': confidence,
      'selected': isSelected,
      'waveformBins': waveform,
    };
  }

  VoiceLine copyWith({
    String? id,
    String? label,
    VoiceStatus? status,
    double? confidence,
    bool? isSelected,
    List<int>? waveform,
  }) {
    return VoiceLine(
      id: id ?? this.id,
      label: label ?? this.label,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      isSelected: isSelected ?? this.isSelected,
      waveform: waveform ?? this.waveform,
    );
  }
}

extension VoiceStatusJson on VoiceStatus {
  String toJson() {
    return switch (this) {
      VoiceStatus.speakingNow => 'speaking_now',
      VoiceStatus.nearby => 'nearby',
      VoiceStatus.background => 'background',
      VoiceStatus.noisy => 'noisy',
      VoiceStatus.lost => 'lost',
    };
  }
}

VoiceStatus voiceStatusFromJson(String? value) {
  return switch (value) {
    'speaking_now' || 'speakingNow' => VoiceStatus.speakingNow,
    'nearby' => VoiceStatus.nearby,
    'background' => VoiceStatus.background,
    'noisy' => VoiceStatus.noisy,
    'lost' => VoiceStatus.lost,
    _ => VoiceStatus.nearby,
  };
}

List<int> _intListFromJson(Object? value) {
  if (value is List) {
    return value.map((v) => (v as num).round()).toList();
  }

  return const [4, 7, 3, 8, 5, 7, 2];
}
