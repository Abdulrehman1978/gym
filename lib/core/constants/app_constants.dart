class AppConstants {
  static const String appName = 'IronLog';
  static const String version = '1.0.0';
  static const int weekdayWorkoutStart = 1;
  static const int weekdayWorkoutEnd = 6;
  static const int restDay = 7;
  static const int deloadWeekInterval = 4;
  static const double deloadWeightFactor = 0.60;
  static const int deloadSetReduction = 1;
  static const int recoveryHours = 48;
  static const double upperBodyProgressionKg = 2.5;
  static const double lowerBodyProgressionKg = 5.0;
  static const int targetProgressSessions = 2;

  // TODO: Replace this URL with your deployed backend URL after deploying backend/main.py.
  // Deploy to Render (free tier): https://render.com — see backend/render.yaml for config.
  // Set ANTHROPIC_API_KEY as an environment variable in the Render dashboard (never commit it).
  // Example deployed URL: https://ironlog-backend.onrender.com
  // DO NOT use 'http://localhost:8000' — on a physical Android device localhost resolves
  // to the device itself, not the dev machine, so it will always fail.
  static const String apiBaseUrl = 'https://gym-z3pk.onrender.com';
}

