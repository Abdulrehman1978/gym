final String createTablesSQL = '''
CREATE TABLE IF NOT EXISTS app_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS body_weight_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  weight_kg REAL NOT NULL,
  notes TEXT
);

CREATE TABLE IF NOT EXISTS exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  muscle_primary TEXT NOT NULL,
  muscle_secondary TEXT,
  equipment TEXT NOT NULL,
  animation_asset TEXT NOT NULL,
  exercise_type TEXT NOT NULL,
  form_cues TEXT NOT NULL,
  common_mistakes TEXT NOT NULL,
  breathing_cue TEXT,
  default_rest_seconds INTEGER DEFAULT 90,
  is_compound INTEGER DEFAULT 0,
  default_rpe_target INTEGER DEFAULT 7
);

CREATE TABLE IF NOT EXISTS workout_days (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  day_number INTEGER NOT NULL,
  day_name TEXT NOT NULL,
  workout_type TEXT NOT NULL,
  workout_label TEXT NOT NULL,
  is_variation INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS day_exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  workout_day_id INTEGER NOT NULL,
  exercise_id INTEGER NOT NULL,
  order_index INTEGER NOT NULL,
  target_sets INTEGER NOT NULL,
  target_reps_min INTEGER NOT NULL,
  target_reps_max INTEGER NOT NULL,
  rest_seconds INTEGER NOT NULL,
  recommended_start_weight REAL,
  has_warmup INTEGER DEFAULT 0,
  warmup_sets_json TEXT,
  notes TEXT,
  FOREIGN KEY (workout_day_id) REFERENCES workout_days(id) ON DELETE CASCADE,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS workout_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  workout_day_id INTEGER NOT NULL,
  started_at TEXT,
  completed_at TEXT,
  duration_minutes INTEGER,
  completed INTEGER DEFAULT 0,
  overall_feeling INTEGER,
  is_deload_week INTEGER DEFAULT 0,
  notes TEXT,
  synced_to_cloud INTEGER DEFAULT 0,
  FOREIGN KEY (workout_day_id) REFERENCES workout_days(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS set_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  exercise_id INTEGER NOT NULL,
  set_number INTEGER NOT NULL,
  weight_kg REAL NOT NULL,
  reps INTEGER NOT NULL,
  is_warmup_set INTEGER DEFAULT 0,
  completed INTEGER DEFAULT 1,
  rpe_actual INTEGER,
  form_rating INTEGER,
  timestamp TEXT,
  FOREIGN KEY (session_id) REFERENCES workout_sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS personal_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  exercise_id INTEGER NOT NULL,
  weight_kg REAL NOT NULL,
  reps INTEGER NOT NULL,
  estimated_1rm REAL,
  date TEXT NOT NULL,
  session_id INTEGER,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE,
  FOREIGN KEY (session_id) REFERENCES workout_sessions(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS weekly_summaries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  week_start TEXT NOT NULL,
  week_end TEXT NOT NULL,
  sessions_completed INTEGER DEFAULT 0,
  total_volume_kg REAL DEFAULT 0,
  ai_report TEXT,
  synced INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS progression_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  exercise_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  old_weight REAL,
  new_weight REAL,
  reason TEXT,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);
''';

final String createIndexesSQL = '''
CREATE INDEX IF NOT EXISTS idx_sets_session ON set_logs(session_id);
CREATE INDEX IF NOT EXISTS idx_sets_exercise ON set_logs(exercise_id);
CREATE INDEX IF NOT EXISTS idx_sessions_date ON workout_sessions(date);
CREATE INDEX IF NOT EXISTS idx_pr_exercise ON personal_records(exercise_id);
''';
