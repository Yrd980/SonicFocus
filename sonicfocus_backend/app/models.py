from __future__ import annotations

from datetime import UTC, datetime
from enum import StrEnum

from pydantic import BaseModel, Field


class VoiceStatus(StrEnum):
    speaking_now = "speaking_now"
    nearby = "nearby"
    background = "background"
    noisy = "noisy"
    lost = "lost"


class SessionState(StrEnum):
    created = "created"
    listening = "listening"
    focused = "focused"
    paused = "paused"
    stopped = "stopped"


class FocusSettings(BaseModel):
    focusStrength: int = Field(default=1, ge=0, le=2)
    voiceEnhance: bool = True
    backgroundReduce: bool = True
    safeAwareness: bool = False


class ProcessingMetrics(BaseModel):
    latencyMs: int = 42
    suppressionDb: int = 24
    targetSnrDb: int = 11
    inputLevelDb: int = -18
    outputLevelDb: int = -12


class VoiceSource(BaseModel):
    id: str
    label: str
    status: VoiceStatus
    confidence: float = Field(ge=0, le=1)
    selected: bool = False
    waveformBins: list[int] = Field(default_factory=list)
    lastSeenAt: datetime = Field(default_factory=lambda: datetime.now(UTC))


class FocusSession(BaseModel):
    id: str
    state: SessionState = SessionState.listening
    selectedSourceId: str | None = None
    settings: FocusSettings = Field(default_factory=FocusSettings)
    metrics: ProcessingMetrics = Field(default_factory=ProcessingMetrics)
    voices: list[VoiceSource] = Field(default_factory=list)
    createdAt: datetime = Field(default_factory=lambda: datetime.now(UTC))
    updatedAt: datetime = Field(default_factory=lambda: datetime.now(UTC))


class CreateSessionResponse(BaseModel):
    session: FocusSession
    eventsUrl: str


class SelectionPatch(BaseModel):
    sourceId: str


class SettingsPatch(BaseModel):
    focusStrength: int | None = Field(default=None, ge=0, le=2)
    voiceEnhance: bool | None = None
    backgroundReduce: bool | None = None
    safeAwareness: bool | None = None


class StatePatch(BaseModel):
    state: SessionState
