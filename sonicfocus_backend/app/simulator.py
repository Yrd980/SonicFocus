from __future__ import annotations

import random
from datetime import UTC, datetime

from .models import FocusSession, ProcessingMetrics, VoiceSource, VoiceStatus


_STATUS_CYCLE = [
    VoiceStatus.speaking_now,
    VoiceStatus.nearby,
    VoiceStatus.background,
    VoiceStatus.noisy,
]


def next_waveform(voice: VoiceSource, tick: int) -> list[int]:
    bins = voice.waveformBins or [4, 5, 3, 6, 4, 5, 3]
    return [
        max(
            1,
            min(
                8,
                value
                + random.choice([-1, 0, 1])
                + (1 if (tick + i) % 7 == 0 else 0),
            ),
        )
        for i, value in enumerate(bins)
    ]


def next_voice(voice: VoiceSource, tick: int) -> VoiceSource:
    status = voice.status
    if tick % 5 == 0 and not voice.selected:
        if voice.status in _STATUS_CYCLE:
            index = _STATUS_CYCLE.index(voice.status)
            status = _STATUS_CYCLE[(index + 1) % len(_STATUS_CYCLE)]
        else:
            status = VoiceStatus.nearby

    confidence_delta = random.uniform(-0.035, 0.035)
    confidence = max(0.45, min(0.98, voice.confidence + confidence_delta))

    return voice.model_copy(
        update={
            "status": status,
            "confidence": round(confidence, 2),
            "waveformBins": next_waveform(voice, tick),
            "lastSeenAt": datetime.now(UTC),
        }
    )


def next_metrics(session: FocusSession, tick: int) -> ProcessingMetrics:
    strength_bonus = session.settings.focusStrength * 4
    return ProcessingMetrics(
        latencyMs=40 + (tick % 6),
        suppressionDb=16 + strength_bonus + random.randint(-1, 2),
        targetSnrDb=8 + strength_bonus + random.randint(-1, 1),
        inputLevelDb=-20 + random.randint(-3, 2),
        outputLevelDb=-14 + random.randint(-2, 3),
    )
