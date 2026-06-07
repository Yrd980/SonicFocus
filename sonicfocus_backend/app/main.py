from __future__ import annotations

import asyncio

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

from .models import (
    FocusSession,
    SettingsPatch,
    StatePatch,
)
from .session_store import store
from .simulator import next_metrics, next_voice

app = FastAPI(title="SonicFocus Mock Backend", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


def _session_state_event(session: FocusSession) -> dict[str, object]:
    return {
        "type": "session_state",
        "sessionId": session.id,
        "session": session.model_dump(mode="json"),
    }


def _apply_websocket_command(session_id: str, message: dict[str, object]) -> FocusSession:
    message_type = message.get("type")
    if message_type == "select_voice":
        return store.select_voice(session_id, str(message.get("sourceId")))
    if message_type == "settings_update":
        settings = message.get("settings")
        if not isinstance(settings, dict):
            settings = {}
        return store.update_settings(session_id, SettingsPatch(**settings))
    if message_type == "state_update":
        return store.update_state(session_id, StatePatch(state=message.get("state")).state)
    if message_type == "stop_session":
        return store.update_state(session_id, StatePatch(state="stopped").state)
    return store.get(session_id)


@app.websocket("/ws/v1/sessions/{session_id}/events")
async def session_events(websocket: WebSocket, session_id: str) -> None:
    await websocket.accept()
    session = store.ensure(session_id)

    await websocket.send_json(
        {
            "type": "voice_snapshot",
            "sessionId": session.id,
            "voices": [voice.model_dump(mode="json") for voice in session.voices],
        }
    )

    tick = 0
    try:
        while True:
            try:
                message = await asyncio.wait_for(websocket.receive_json(), timeout=1)
                if isinstance(message, dict):
                    session = _apply_websocket_command(session_id, message)
                    await websocket.send_json(_session_state_event(session))
            except TimeoutError:
                pass

            tick += 1

            session = store.get(session_id)
            voices = [next_voice(voice, tick) for voice in session.voices]
            metrics = next_metrics(session, tick)
            session = store.update_realtime(session_id, voices=voices, metrics=metrics)

            for voice in voices:
                await websocket.send_json(
                    {
                        "type": "waveform_update",
                        "sessionId": session.id,
                        "sourceId": voice.id,
                        "bins": voice.waveformBins,
                    }
                )

            if tick % 2 == 0:
                selected = next(
                    (voice for voice in voices if voice.id == session.selectedSourceId),
                    voices[0],
                )
                await websocket.send_json(
                    {
                        "type": "voice_update",
                        "sessionId": session.id,
                        "voice": selected.model_dump(mode="json"),
                    }
                )

            await websocket.send_json(
                {
                    "type": "processing_metrics",
                    "sessionId": session.id,
                    "metrics": session.metrics.model_dump(mode="json"),
                }
            )

            if tick % 4 == 0:
                await websocket.send_json(
                    {
                        "type": "session_state",
                        "sessionId": session.id,
                        "state": session.state,
                        "selectedSourceId": session.selectedSourceId,
                    }
                )
    except WebSocketDisconnect:
        return
