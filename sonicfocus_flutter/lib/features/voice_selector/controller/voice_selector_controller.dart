import 'package:flutter/foundation.dart';

import '../model/voice_line.dart';

const demoVoiceLines = [
  VoiceLine(
    id: 'voice_a',
    label: 'Voice A',
    status: VoiceStatus.speakingNow,
    confidence: 0.92,
    isSelected: true,
    waveform: [6, 8, 4, 7, 5, 8, 3],
  ),
  VoiceLine(
    id: 'voice_b',
    label: 'Voice B',
    status: VoiceStatus.nearby,
    confidence: 0.81,
    isSelected: false,
    waveform: [4, 2, 5, 3, 4, 2, 3],
  ),
  VoiceLine(
    id: 'voice_c',
    label: 'Voice C',
    status: VoiceStatus.background,
    confidence: 0.67,
    isSelected: false,
    waveform: [2, 2, 3, 2, 2, 1, 2],
  ),
];

class VoiceSelectorController extends ChangeNotifier {
  VoiceSelectorController() : _voices = demoVoiceLines;

  List<VoiceLine> _voices;

  List<VoiceLine> get voices => _voices;

  VoiceLine get selectedVoice => _voices.firstWhere((v) => v.isSelected);

  void selectVoice(String id) {
    _voices = _voices.map((v) => v.copyWith(isSelected: v.id == id)).toList();
    notifyListeners();
  }
}
