import 'package:flutter/foundation.dart';

import '../model/voice_line.dart';

class VoiceSelectorController extends ChangeNotifier {
  VoiceSelectorController()
      : _voices = const [
          VoiceLine(
            id: 'voice_a',
            label: 'Voice A',
            status: VoiceStatus.speakingNow,
            confidence: 0.92,
            isSelected: true,
          ),
          VoiceLine(
            id: 'voice_b',
            label: 'Voice B',
            status: VoiceStatus.nearby,
            confidence: 0.81,
            isSelected: false,
          ),
          VoiceLine(
            id: 'voice_c',
            label: 'Voice C',
            status: VoiceStatus.background,
            confidence: 0.67,
            isSelected: false,
          ),
        ];

  List<VoiceLine> _voices;

  List<VoiceLine> get voices => _voices;

  VoiceLine get selectedVoice => _voices.firstWhere((v) => v.isSelected);

  void selectVoice(String id) {
    _voices = _voices.map((v) => v.copyWith(isSelected: v.id == id)).toList();
    notifyListeners();
  }
}
