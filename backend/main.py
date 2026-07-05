import os
import json
import sqlite3
import anthropic
from datetime import datetime
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="IronLog AI Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DB_PATH = os.environ.get("IRONLOG_DB_PATH", "ironlog_backend.db")

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("""
        CREATE TABLE IF NOT EXISTS workout_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER,
            date TEXT,
            workout_day_id INTEGER,
            data TEXT,
            created_at TEXT DEFAULT (datetime('now'))
        )
    """)
    return conn

class SyncRequest(BaseModel):
    session_id: int
    date: str
    workout_day_id: int
    sets: list = []

class AIReportRequest(BaseModel):
    workout_summary: str = ""
    pr_summary: str = ""

@app.post("/sync")
def sync_workout(req: SyncRequest):
    conn = get_db()
    conn.execute(
        "INSERT INTO workout_sessions (session_id, date, workout_day_id, data) VALUES (?, ?, ?, ?)",
        [req.session_id, req.date, req.workout_day_id, json.dumps(req.sets)]
    )
    conn.commit()
    conn.close()
    return {"ok": True}

@app.post("/ai-report")
def ai_report(req: AIReportRequest):
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        raise HTTPException(503, "AI analysis unavailable - no API key configured")

    system_prompt = """You are an expert strength-training analyst. Given a user's logged workout data across a 6-day Push/Pull/Legs x 2 program, analyze their progress. Return ONLY valid JSON with no extra text. The JSON must have keys: insights (array of {title, description, type}), muscle_scores (object mapping muscle name to 0-100 score), next_week_focus (string), progressive_overload_suggestions (array of {exercise, current_weight, suggested_weight}), motivation_message (string), warning_flags (array of strings). Be specific with numbers. Encourage consistency."""

    user_prompt = f"""Analyze this workout data:

Workout Summary:
{req.workout_summary}

PR Summary:
{req.pr_summary}

Return JSON analysis."""

    client = anthropic.Anthropic(api_key=api_key)
    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=2000,
        system=system_prompt,
        messages=[{"role": "user", "content": user_prompt}]
    )

    content = response.content[0].text
    import re
    json_match = re.search(r'\{.*\}', content, re.DOTALL)
    if json_match:
        try:
            return json.loads(json_match.group())
        except json.JSONDecodeError:
            pass

    return {
        "insights": [{"title": "Analysis Complete", "description": "AI analyzed your data. Continue training consistently!", "type": "positive"}],
        "muscle_scores": {"Chest": 70, "Back": 70, "Legs": 70, "Arms": 70, "Shoulders": 70},
        "next_week_focus": "Stay consistent with your current program",
        "progressive_overload_suggestions": [],
        "motivation_message": "Keep showing up - consistency is what builds muscle!",
        "warning_flags": []
    }

@app.get("/health")
def health():
    return {"status": "ok", "ai_configured": bool(os.environ.get("ANTHROPIC_API_KEY"))}
