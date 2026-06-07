from __future__ import annotations

from copy import deepcopy
from datetime import UTC, datetime
from uuid import uuid4

from fastapi import HTTPException

from .models import (
    FocusSession,
    ProcessingMetrics,
    SessionState,
    SettingsPatch,
    VoiceSource,
    VoiceStatus,
)


def _now() -> datetime:
    return datetime.now(UTC)


def _mark_selected(
    voices: list[VoiceSource],
    selected_source_id: str | None,
) -> list[VoiceSource]:
    if selected_source_id is None:
        return voices
    return [
        voice.model_copy(update={"selected": voice.id == selected_source_id})
        for voice in voices
    ]


def _demo_voices() -> list[VoiceSource]:
    return [
        VoiceSource(
            id="voice_a",
            label="Voice A",
            status=VoiceStatus.speaking_now,
            confidence=0.92,
            selected=True,
            waveformBins=[6, 8, 4, 7, 5, 8, 3],
        ),
        VoiceSource(
            id="voice_b",
            label="Voice B",
            status=VoiceStatus.nearby,
            confidence=0.81,
            waveformBins=[4, 2, 5, 3, 4, 2, 3],
        ),
        VoiceSource(
            id="voice_c",
            label="Voice C",
            status=VoiceStatus.background,
            confidence=0.67,
            waveformBins=[2, 2, 3, 2, 2, 1, 2],
        ),
    ]


class SessionStore:
    def __init__(self) -> None:
        self._sessions: dict[str, FocusSession] = {}

    def create(self, session_id: str | None = None) -> FocusSession:
        voices = _demo_voices()
        session = FocusSession(
            id=session_id or f"sess_{uuid4().hex[:12]}",
            state=SessionState.listening,
            selectedSourceId=voices[0].id,
            voices=voices,
        )
        self._sessions[session.id] = session
        return deepcopy(session)

    def ensure(self, session_id: str) -> FocusSession:
        session = self._sessions.get(session_id)
        if session is not None:
            return deepcopy(session)
        return self.create(session_id=session_id)

    def get(self, session_id: str) -> FocusSession:
        session = self._sessions.get(session_id)
        if session is None:
            raise HTTPException(status_code=404, detail="Session not found")
        return deepcopy(session)

    def get_mutable(self, session_id: str) -> FocusSession:
        session = self._sessions.get(session_id)
        if session is None:
            raise HTTPException(status_code=404, detail="Session not found")
        return session

    def voices(self, session_id: str) -> list[VoiceSource]:
        return self.get(session_id).voices

    def select_voice(self, session_id: str, source_id: str) -> FocusSession:
        session = self.get_mutable(session_id)
        if not any(voice.id == source_id for voice in session.voices):
            raise HTTPException(status_code=404, detail="Voice source not found")

        session.selectedSourceId = source_id
        session.voices = _mark_selected(session.voices, source_id)
        session.updatedAt = _now()
        return deepcopy(session)

    def update_settings(self, session_id: str, patch: SettingsPatch) -> FocusSession:
        session = self.get_mutable(session_id)
        updates = patch.model_dump(exclude_unset=True, exclude_none=True)
        session.settings = session.settings.model_copy(update=updates)
        session.updatedAt = _now()
        return deepcopy(session)

    def update_state(self, session_id: str, state: SessionState) -> FocusSession:
        session = self.get_mutable(session_id)
        session.state = state
        session.updatedAt = _now()
        return deepcopy(session)

    def update_realtime(
        self,
        session_id: str,
        voices: list[VoiceSource] | None = None,
        metrics: ProcessingMetrics | None = None,
    ) -> FocusSession:
        session = self.get_mutable(session_id)
        if voices is not None:
            session.voices = _mark_selected(voices, session.selectedSourceId)
        if metrics is not None:
            session.metrics = metrics
        session.updatedAt = _now()
        return deepcopy(session)

    def delete(self, session_id: str) -> None:
        if self._sessions.pop(session_id, None) is None:
            raise HTTPException(status_code=404, detail="Session not found")


store = SessionStore()
