enum VoiceStatus { speakingNow, nearby, background, noisy }

class VoiceLine {
  const VoiceLine({
    required this.id,
    required this.label,
    required this.status,
    required this.confidence,
    required this.isSelected,
  });

  final String id;
  final String label;
  final VoiceStatus status;
  final double confidence;
  final bool isSelected;

  VoiceLine copyWith({bool? isSelected}) {
    return VoiceLine(
      id: id,
      label: label,
      status: status,
      confidence: confidence,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
