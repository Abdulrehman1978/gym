from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import json
import os

app = FastAPI(title="IronLog AI Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class SyncData(BaseModel):
    session: dict
    sets: list

class ReportData(BaseModel):
    sessions: list
    sets: list
    personal_records: list
    week_start: str

@app.get("/")
async def root():
    return {"status": "online", "app": "IronLog AI Backend"}

@app.post("/sync")
async def sync_session(data: SyncData):
    try:
        os.makedirs("data", exist_ok=True)
        filepath = f"data/session_{data.session.get('id', 'unknown')}.json"
        with open(filepath, "w") as f:
            json.dump({"session": data.session, "sets": data.sets}, f)
        return {"status": "synced", "session_id": data.session.get("id")}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/ai-report")
async def generate_ai_report(data: ReportData):
    try:
        workout_summary = _build_workout_summary(data.sessions, data.sets)
        pr_summary = _build_pr_summary(data.personal_records)

        report = _generate_mock_report(workout_summary, pr_summary)
        return report
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def _build_workout_summary(sessions: list, sets: list) -> str:
    lines = []
    for session in sessions[-24:]:
        session_sets = [s for s in sets if s.get("session_id") == session.get("id")]
        volume = sum(float(s.get("weight_kg", 0)) * int(s.get("reps", 0)) for s in session_sets)
        lines.append(
            f"{session.get('date')}: {session.get('workout_type')} day, "
            f"{len(session_sets)} sets, {volume:.0f}kg total volume"
        )
    return "\n".join(lines)

def _build_pr_summary(prs: list) -> str:
    return "\n".join([
        f"Exercise ID {pr.get('exercise_id')}: "
        f"{pr.get('weight_kg')}kg x {pr.get('reps')} reps "
        f"on {pr.get('date')}"
        for pr in prs
    ])

def _generate_mock_report(workout_summary: str, pr_summary: str) -> dict:
    pr_count = len(pr_summary.split("\n")) if pr_summary.strip() else 0
    return {
        "insights": [
            {
                "icon": "\U0001f4c8",
                "title": "Progress Tracking Active",
                "description": f"You have {pr_count} personal records logged. Keep pushing to build more strength!",
                "type": "positive"
            },
            {
                "icon": "\u26a0\ufe0f",
                "title": "Volume Balance",
                "description": "Ensure you're hitting all muscle groups equally. Consider adding more leg volume if lagging.",
                "type": "warning"
            },
            {
                "icon": "\U0001f4a1",
                "title": "Try Progressive Overload",
                "description": "Aim to add 2.5kg or 1-2 more reps each week on your compound lifts.",
                "type": "suggestion"
            }
        ],
        "muscle_scores": {
            "chest": 75, "back": 72, "legs": 60,
            "shoulders": 70, "biceps": 68, "triceps": 65, "forearms": 55
        },
        "next_week_focus": [
            "Focus on hitting all 6 sessions this week",
            "Try increasing weight on your main compound lift",
            "Add an extra set to lagging muscle groups"
        ],
        "week_summary": {
            "sessions_quality": "Good progress this week",
            "strongest_muscle": "Chest",
            "needs_attention": "Legs & Forearms",
            "motivation": "Consistency is key! Every workout brings you closer to your goals."
        },
        "progressive_overload": [
            {"exercise": "Bench Press", "current": "40kg", "suggested": "42.5kg"},
            {"exercise": "Lat Pulldown", "current": "35kg", "suggested": "37.5kg"}
        ]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
