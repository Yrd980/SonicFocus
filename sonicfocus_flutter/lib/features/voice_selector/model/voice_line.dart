enum VoiceStatus { speakingNow, nearby, background, noisy }

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

  VoiceLine copyWith({bool? isSelected}) {
    return VoiceLine(
      id: id,
      label: label,
      status: status,
      confidence: confidence,
      isSelected: isSelected ?? this.isSelected,
      waveform: waveform,
    );
  }
}
