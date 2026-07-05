import 'database_helper.dart';

class SeedData {
  static Future<void> seedAll(DatabaseHelper db) async {
    final isEmpty = await db.isTableEmpty('exercises');
    if (!isEmpty) return;

    await db.transaction((tx) async {
      for (final exercise in _exercises) {
        await tx.insert('exercises', exercise);
      }

      for (final day in _workoutDays) {
        await tx.insert('workout_days', day);
      }

      for (final entry in _dayExercises) {
        await tx.insert('day_exercises', entry);
      }
    });
  }

  static const List<Map<String, dynamic>> _exercises = [
    // --- PUSH DAY EXERCISES (Monday + Thursday) ---
    // 1 - Flat Barbell Bench Press
    {
      'id': 1,
      'name': 'Flat Barbell Bench Press',
      'muscle_primary': 'Chest',
      'muscle_secondary': 'Triceps, Front Delt',
      'equipment': 'barbell, flat_bench',
      'animation_asset': 'lottie/bench_press_flat.json',
      'exercise_type': 'compound',
      'form_cues':
          'Feet flat on floor, full contact|Grip 1.5x shoulder width|Shoulder blades squeezed together and DOWN|Slight natural lower back arch|Bar touches lower chest (nipple line)|Elbows at 45-60 degree angle|Push bar slightly back toward face at top|Full lockout each rep',
      'common_mistakes':
          'Elbows flared at 90 degrees (shoulder injury risk)|Bouncing bar off chest|Hips lifting off bench|Partial range of motion|Bar path going straight up',
      'breathing_cue':
          'Big breath before descent, hold through descent, exhale forcefully on push',
      'default_rest_seconds': 120,
      'is_compound': 1,
      'default_rpe_target': 8,
    },
    // 2 - Incline Dumbbell Press
    {
      'id': 2,
      'name': 'Incline Dumbbell Press',
      'muscle_primary': 'Upper Chest',
      'muscle_secondary': 'Front Delt',
      'equipment': 'dumbbells, incline_bench',
      'animation_asset': 'lottie/incline_db_press.json',
      'exercise_type': 'compound',
      'form_cues':
          'Bench at 30 degrees (not 45)|Dumbbells at shoulder height, neutral grip|Press up and slightly inward|Stop just before dumbbells touch|Feel upper chest stretch at bottom|Control descent 2 seconds down',
      'common_mistakes':
          'Bench too steep (45 degrees works shoulders more)|Arms flaring out|Not going deep enough',
      'breathing_cue': 'Exhale on press, inhale lowering',
      'default_rest_seconds': 90,
      'is_compound': 1,
      'default_rpe_target': 7,
    },
    // 3 - Pec Deck Fly Machine
    {
      'id': 3,
      'name': 'Pec Deck Fly Machine',
      'muscle_primary': 'Chest',
      'muscle_secondary': 'Front Delt',
      'equipment': 'pec_deck_machine',
      'animation_asset': 'lottie/pec_deck.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Seat height — handles at chest height|Slight bend in elbows (10-15 degrees)|Don\'t go past comfortable stretch|Squeeze chest hard 1 second at center|Slow return 3 seconds',
      'common_mistakes':
          'Straight arms (elbow joint stress)|Going too heavy (loses chest feel)|Letting arms fly back too far',
      'breathing_cue': 'Exhale squeezing, inhale opening',
      'default_rest_seconds': 60,
      'is_compound': 0,
      'default_rpe_target': 7,
    },
    // 4 - Dumbbell Lateral Raise
    {
      'id': 4,
      'name': 'Dumbbell Lateral Raise',
      'muscle_primary': 'Side Delts',
      'muscle_secondary': 'Traps',
      'equipment': 'dumbbells',
      'animation_asset': 'lottie/lateral_raise.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Lead with elbows not wrists|Raise to shoulder height (not higher)|Lean forward 15 degrees|Thumbs slightly lower at top|2 second hold at top|3 second controlled descent',
      'common_mistakes':
          'Shrugging (traps doing the work)|Swinging dumbbells up|Raising above shoulder (rotator cuff risk)',
      'breathing_cue': 'Exhale raising, inhale lowering',
      'default_rest_seconds': 60,
      'is_compound': 0,
      'default_rpe_target': 7,
    },
    // 5 - Cable Pushdown (Rope)
    {
      'id': 5,
      'name': 'Cable Pushdown (Rope)',
      'muscle_primary': 'Triceps',
      'muscle_secondary': '',
      'equipment': 'cable_machine, rope_attachment',
      'animation_asset': 'lottie/cable_pushdown_rope.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Stand close to cable machine|Lean forward 10-15 degrees|Elbows glued to sides|Spread rope at bottom (supinate wrists)|Full extension squeeze tricep',
      'common_mistakes':
          'Elbows moving away from body|Not going to full extension|Using body momentum',
      'breathing_cue': 'Exhale pushing down, inhale returning',
      'default_rest_seconds': 60,
      'is_compound': 0,
      'default_rpe_target': 7,
    },
    // 6 - Dips (Tricep Focus)
    {
      'id': 6,
      'name': 'Dips (Tricep Focus)',
      'muscle_primary': 'Triceps',
      'muscle_secondary': 'Lower Chest',
      'equipment': 'dips_station',
      'animation_asset': 'lottie/dips_tricep.json',
      'exercise_type': 'compound',
      'form_cues':
          'Torso upright (vertical)|Elbows tracking back, close to body|Lower until upper arm parallel to floor|Full lockout at top|Don\'t shrug at bottom',
      'common_mistakes':
          'Leaning forward (chest focus)|Elbows flaring out|Not going deep enough|Partial lockout',
      'breathing_cue': 'Inhale lowering, exhale pushing up',
      'default_rest_seconds': 90,
      'is_compound': 1,
      'default_rpe_target': 7,
    },
    // 7 - Incline Barbell Bench Press
    {
      'id': 7,
      'name': 'Incline Barbell Bench Press',
      'muscle_primary': 'Upper Chest',
      'muscle_secondary': 'Front Delt, Triceps',
      'equipment': 'barbell, incline_bench',
      'animation_asset': 'lottie/bench_press_incline.json',
      'exercise_type': 'compound',
      'form_cues':
          'Bench 30-35 degrees|Bar touches upper chest|Elbows slightly more forward than flat|Same form as flat bench|Lighter than flat is normal',
      'common_mistakes':
          'Bench too steep|Bar path too vertical|Arching lower back excessively',
      'breathing_cue':
          'Same as flat bench — big breath, hold, exhale press',
      'default_rest_seconds': 120,
      'is_compound': 1,
      'default_rpe_target': 8,
    },
    // 8 - Smith Machine Shoulder Press
    {
      'id': 8,
      'name': 'Smith Machine Shoulder Press',
      'muscle_primary': 'Front Delts',
      'muscle_secondary': 'Side Delts, Triceps',
      'equipment': 'smith_machine, adjustable_bench',
      'animation_asset': 'lottie/smith_shoulder_press.json',
      'exercise_type': 'compound',
      'form_cues':
          'Bench fully upright (90 degrees)|Bar path down to chin level|Don\'t lock elbows aggressively|Elbows slightly forward (not flared)|Don\'t arch lower back',
      'common_mistakes':
          'Leaning back too much|Locking elbows at top|Flaring elbows out',
      'breathing_cue': 'Exhale pressing up, inhale lowering',
      'default_rest_seconds': 90,
      'is_compound': 1,
      'default_rpe_target': 7,
    },
    // 9 - Decline Barbell Bench Press
    {
      'id': 9,
      'name': 'Decline Barbell Bench Press',
      'muscle_primary': 'Lower Chest',
      'muscle_secondary': 'Triceps',
      'equipment': 'barbell, decline_bench',
      'animation_asset': 'lottie/bench_press_decline.json',
      'exercise_type': 'compound',
      'form_cues':
          'Feet secured in decline pad|Bar touches lower pec|Same elbow angle as flat bench|Control bar — gravity works against you|Most people stronger on decline',
      'common_mistakes':
          'Not securing feet properly|Bar path too low|Bouncing off chest',
      'breathing_cue': 'Same as flat bench',
      'default_rest_seconds': 90,
      'is_compound': 1,
      'default_rpe_target': 7,
    },
    // 10 - Cable Fly (High to Low)
    {
      'id': 10,
      'name': 'Cable Fly (High to Low)',
      'muscle_primary': 'Lower Chest',
      'muscle_secondary': 'Chest',
      'equipment': 'cable_machine',
      'animation_asset': 'lottie/cable_fly_high_low.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Cables at highest position|Step forward for tension|Lean forward 15-20 degrees|Slight elbow bend fixed|Bring hands together cross slightly|Squeeze chest 1 second',
      'common_mistakes':
          'Bending/straightening elbows during rep|Standing too close to machine|Not crossing hands enough',
      'breathing_cue': 'Exhale bringing together, inhale opening',
      'default_rest_seconds': 60,
      'is_compound': 0,
      'default_rpe_target': 6,
    },
    // 11 - Overhead Cable Tricep Extension
    {
      'id': 11,
      'name': 'Overhead Cable Tricep Extension',
      'muscle_primary': 'Triceps',
      'muscle_secondary': '',
      'equipment': 'cable_machine, rope_attachment',
      'animation_asset': 'lottie/overhead_cable_tricep.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Face away from cable machine|Hold rope behind head|Elbows pointing forward|Elbows stay in place|Full extension overhead|Feel long head stretch',
      'common_mistakes':
          'Elbows moving|Not going to full extension|Leaning forward',
      'breathing_cue': 'Exhale extending, inhale lowering',
      'default_rest_seconds': 60,
      'is_compound': 0,
      'default_rpe_target': 7,
    },
    // 12 - Dumbbell Front Raise
    {
      'id': 12,
      'name': 'Dumbbell Front Raise',
      'muscle_primary': 'Front Delts',
      'muscle_secondary': '',
      'equipment': 'dumbbells',
      'animation_asset': 'lottie/front_raise.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Slight bend in elbow|Raise to shoulder height only|Controlled 3 second descent|Only 2 sets — front delt already worked',
      'common_mistakes':
          'Using body momentum|Raising above shoulder level|Locking elbows',
      'breathing_cue': 'Exhale raising, inhale lowering',
      'default_rest_seconds': 60,
      'is_compound': 0,
      'default_rpe_target': 6,
    },

    // --- PULL DAY EXERCISES (Tuesday + Friday) ---
    // 13 - Lat Pulldown (Wide Overhand)
    {
      'id': 13,
      'name': 'Lat Pulldown (Wide Overhand)',
      'muscle_primary': 'Lats',
      'muscle_secondary': 'Biceps, Rear Delt',
      'equipment': 'lat_pulldown_machine',
      'animation_asset': 'lottie/lat_pulldown_wide.json',
      'exercise_type': 'compound',
      'form_cues':
          'Grip wider than shoulders|Lean back 10-15 degrees max|Pull bar to upper chest|Lead with elbows — drive to hips|Chest tall throughout|Full arm extension at top|Squeeze lats at bottom',
      'common_mistakes':
          'Pulling to chin or forehead|Leaning back 45+ degrees|Arms bending before elbows initiate|Rushing the return',
      'breathing_cue': 'Exhale pulling down, inhale returning',
      'default_rest_seconds': 120,
      'is_compound': 1,
      'default_rpe_target': 8,
    },
    // 14 - Seated Cable Row (V-Bar)
    {
      'id': 14,
      'name': 'Seated Cable Row (V-Bar)',
      'muscle_primary': 'Mid Back',
      'muscle_secondary': 'Rhomboids, Lower Lats',
      'equipment': 'cable_machine, v_bar',
      'animation_asset': 'lottie/seated_cable_row.json',
      'exercise_type': 'compound',
      'form_cues':
          'Sit tall chest up before every rep|Slight lower back arch|Pull handle to belly button|Drive elbows past body|Squeeze shoulder blades at end|Full arm extension at front',
      'common_mistakes':
          'Rounding lower back|Pulling to chest|Using body swing|Not fully extending arms',
      'breathing_cue': 'Exhale pulling in, inhale extending',
      'default_rest_seconds': 120,
      'is_compound': 1,
      'default_rpe_target': 8,
    },
    // 15 - Dumbbell Single Arm Row
    {
      'id': 15,
      'name': 'Dumbbell Single Arm Row',
      'muscle_primary': 'Lats',
      'muscle_secondary': 'Rhomboids, Rear Delt',
      'equipment': 'dumbbells, adjustable_bench',
      'animation_asset': 'lottie/db_single_row.json',
      'exercise_type': 'compound',
      'form_cues':
          'Knee and hand on bench|Back flat parallel to floor|Let dumbbell hang full stretch|Pull elbow to ceiling toward hip|No torso rotation',
      'common_mistakes':
          'Rotating torso|Pulling elbow out to side|Not going to full stretch|Using too much body English',
      'breathing_cue': 'Exhale pulling, inhale lowering',
      'default_rest_seconds': 60,
      'is_compound': 1,
      'default_rpe_target': 7,
    },
    // 16 - Preacher Curl (EZ Bar)
    {
      'id': 16,
      'name': 'Preacher Curl (EZ Bar)',
      'muscle_primary': 'Biceps',
      'muscle_secondary': '',
      'equipment': 'preacher_curl_machine, ez_bar',
      'animation_asset': 'lottie/preacher_curl_bar.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Upper arms fully flat on pad|Full extension at bottom critical|Curl to chin level squeeze|3 second controlled descent every rep',
      'common_mistakes':
          'Elbows lifting off pad|Cutting bottom range short|Swinging to get weight up',
      'breathing_cue': 'Exhale curling, inhale lowering',
      'default_rest_seconds': 75,
      'is_compound': 0,
      'default_rpe_target': 7,
    },
    // 17 - Hammer Curl (Alternating)
    {
      'id': 17,
      'name': 'Hammer Curl (Alternating)',
      'muscle_primary': 'Brachialis',
      'muscle_secondary': 'Brachioradialis, Biceps',
      'equipment': 'dumbbells',
      'animation_asset': 'lottie/hammer_curl.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Neutral grip throughout (thumbs up)|Elbows pinned to sides|Full extension at bottom each rep|Alternate arms — one resting',
      'common_mistakes':
          'Using body momentum|Not going to full extension|Supinating wrist (changes to regular curl)',
      'breathing_cue': 'Exhale curling, inhale lowering',
      'default_rest_seconds': 60,
      'is_compound': 0,
      'default_rpe_target': 7,
    },
    // 18 - Forearm Machine (Wrist Curl)
    {
      'id': 18,
      'name': 'Forearm Machine (Wrist Curl)',
      'muscle_primary': 'Forearms',
      'muscle_secondary': '',
      'equipment': 'forearm_machine',
      'animation_asset': 'lottie/forearm_curl.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Forearms fully flat on pad|Full range wrist drops then curls fully|Slow controlled no jerking|Train both directions always',
      'common_mistakes':
          'Not going to full stretch|Using momentum|Only training one direction',
      'breathing_cue': 'Breathe normally throughout',
      'default_rest_seconds': 45,
      'is_compound': 0,
      'default_rpe_target': 6,
    },
    // 19 - Lat Pulldown (Underhand)
    {
      'id': 19,
      'name': 'Lat Pulldown (Underhand)',
      'muscle_primary': 'Lats',
      'muscle_secondary': 'Biceps, Lower Lats',
      'equipment': 'lat_pulldown_machine',
      'animation_asset': 'lottie/lat_pulldown_underhand.json',
      'exercise_type': 'compound',
      'form_cues':
          'Underhand grip shoulder width|More bicep + lower lat activation|Pull bar to upper chest|Lead with elbows|Squeeze at bottom',
      'common_mistakes':
          'Same as wide grip|Leaning too far back',
      'breathing_cue': 'Exhale pulling down, inhale returning',
      'default_rest_seconds': 120,
      'is_compound': 1,
      'default_rpe_target': 8,
    },
    // 20 - Barbell Bent Over Row
    {
      'id': 20,
      'name': 'Barbell Bent Over Row',
      'muscle_primary': 'Full Back',
      'muscle_secondary': 'Rhomboids, Lower Lats, Biceps',
      'equipment': 'barbell',
      'animation_asset': 'lottie/barbell_row.json',
      'exercise_type': 'compound',
      'form_cues':
          'Hinge at hips 45 degrees|Back flat and neutral|Bar hangs below chest|Pull bar to belly button|Elbows close to body|Squeeze shoulder blades at top|Full arm extension at bottom',
      'common_mistakes':
          'Rounding back under load|Using body swing|Pulling to chest|Not fully extending arms',
      'breathing_cue':
          'Exhale pulling, inhale lowering — brace core',
      'default_rest_seconds': 120,
      'is_compound': 1,
      'default_rpe_target': 8,
    },
    // 21 - Straight Arm Cable Pulldown
    {
      'id': 21,
      'name': 'Straight Arm Cable Pulldown',
      'muscle_primary': 'Lats',
      'muscle_secondary': 'Triceps (dynamic stability)',
      'equipment': 'cable_machine, straight_bar',
      'animation_asset': 'lottie/straight_arm_pulldown.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Stand back from machine|Arms straight never bend elbows|Slight forward hinge|Pull bar from overhead to thighs|Feel lats stretch at top',
      'common_mistakes':
          'Bending elbows|Using too much weight|Not getting full stretch at top',
      'breathing_cue': 'Exhale pulling down, inhale raising',
      'default_rest_seconds': 75,
      'is_compound': 0,
      'default_rpe_target': 7,
    },
    // 22 - Preacher Curl (Dumbbell)
    {
      'id': 22,
      'name': 'Preacher Curl (Dumbbell)',
      'muscle_primary': 'Biceps',
      'muscle_secondary': '',
      'equipment': 'dumbbells, preacher_curl_machine',
      'animation_asset': 'lottie/preacher_curl_db.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Same form as bar version|Dumbbell allows more range|Full extension at bottom|Squeeze at top',
      'common_mistakes': 'Same as bar version',
      'breathing_cue': 'Exhale curling, inhale lowering',
      'default_rest_seconds': 75,
      'is_compound': 0,
      'default_rpe_target': 7,
    },
    // 23 - Cable Curl (Straight Bar)
    {
      'id': 23,
      'name': 'Cable Curl (Straight Bar)',
      'muscle_primary': 'Biceps',
      'muscle_secondary': '',
      'equipment': 'cable_machine, straight_bar',
      'animation_asset': 'lottie/cable_curl.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Stand close to machine|Elbows pinned to sides|Curl all the way up squeeze|Constant tension unlike dumbbells|Slow descent',
      'common_mistakes':
          'Elbows moving forward|Using body momentum|Not going to full contraction',
      'breathing_cue': 'Exhale curling, inhale lowering',
      'default_rest_seconds': 60,
      'is_compound': 0,
      'default_rpe_target': 7,
    },

    // --- LEG DAY EXERCISES (Wednesday + Saturday) ---
    // 24 - Smith Machine Squat
    {
      'id': 24,
      'name': 'Smith Machine Squat',
      'muscle_primary': 'Quads',
      'muscle_secondary': 'Glutes, Hamstrings',
      'equipment': 'smith_machine',
      'animation_asset': 'lottie/smith_squat.json',
      'exercise_type': 'compound',
      'form_cues':
          'Feet forward of bar line (Smith specific)|Feet shoulder width, toes 30 degrees out|Bar on upper traps not neck|Create shelf with upper back|Take big breath brace core|Push knees out in toe direction|Descend until thighs parallel|Drive through heels|Knees never cave inward',
      'common_mistakes':
          'Heels rising|Knees caving in|Only going halfway down|Forward lean|Bar on neck (dangerous)',
      'breathing_cue':
          'Big inhale hold through descent, exhale HARD up (Valsalva)',
      'default_rest_seconds': 120,
      'is_compound': 1,
      'default_rpe_target': 8,
    },
    // 25 - Leg Extension Machine
    {
      'id': 25,
      'name': 'Leg Extension Machine',
      'muscle_primary': 'Quads',
      'muscle_secondary': '',
      'equipment': 'leg_extension_machine',
      'animation_asset': 'lottie/leg_extension.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Seat back so knees align with pivot|Ankle pad just above ankle bone|Full extension squeeze quads hard|1 second hold at top|3 second controlled return|Don\'t let stack touch between reps',
      'common_mistakes':
          'Kicking up with momentum|Not reaching full extension|Hips lifting off seat',
      'breathing_cue': 'Exhale extending, inhale lowering',
      'default_rest_seconds': 75,
      'is_compound': 0,
      'default_rpe_target': 7,
    },
    // 26 - Hamstring Curl Machine
    {
      'id': 26,
      'name': 'Hamstring Curl Machine',
      'muscle_primary': 'Hamstrings',
      'muscle_secondary': '',
      'equipment': 'hamstring_curl_machine',
      'animation_asset': 'lottie/hamstring_curl.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Hips pressed down into pad — non-negotiable|Curl until heel approaches glutes|Squeeze hamstrings at peak|3 second controlled return|Toes pointed slightly',
      'common_mistakes':
          'Hips lifting (reduces ROM)|Letting weight drop on return|Going too fast',
      'breathing_cue': 'Exhale curling, inhale lowering',
      'default_rest_seconds': 75,
      'is_compound': 0,
      'default_rpe_target': 7,
    },
    // 27 - Romanian Deadlift (Barbell)
    {
      'id': 27,
      'name': 'Romanian Deadlift (Barbell)',
      'muscle_primary': 'Hamstrings',
      'muscle_secondary': 'Glutes, Lower Back',
      'equipment': 'barbell',
      'animation_asset': 'lottie/romanian_deadlift.json',
      'exercise_type': 'compound',
      'form_cues':
          'Start standing bar at hips|Slight bend in knees locked throughout|Push hips back like closing a door|Bar drags down legs touching shins|Feel hamstring stretch at shin level|Drive hips forward return squeeze glutes|Back neutral throughout',
      'common_mistakes':
          'Rounding lower back (reduce weight!)|Bending knees too much (becomes squat)|Bar drifting forward from body|Looking in mirror (neck strain)',
      'breathing_cue':
          'Inhale lowering, exhale driving hips forward',
      'default_rest_seconds': 120,
      'is_compound': 1,
      'default_rpe_target': 8,
    },
    // 28 - Hanging Leg Raise
    {
      'id': 28,
      'name': 'Hanging Leg Raise',
      'muscle_primary': 'Lower Abs',
      'muscle_secondary': 'Hip Flexors, Core',
      'equipment': 'hanging_leg_raise_station',
      'animation_asset': 'lottie/hanging_leg_raise.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Arms in support position|Start hanging legs straight|Raise legs until parallel to floor|Controlled 3 second descent|Don\'t swing|If too hard: bend knees',
      'common_mistakes':
          'Swinging body|Not going to parallel|Raising too fast|Using only hip flexors',
      'breathing_cue': 'Exhale raising, inhale lowering',
      'default_rest_seconds': 60,
      'is_compound': 0,
      'default_rpe_target': 7,
    },
    // 29 - Bulgarian Split Squat (Smith)
    {
      'id': 29,
      'name': 'Bulgarian Split Squat (Smith)',
      'muscle_primary': 'Quads',
      'muscle_secondary': 'Glutes, Hamstrings',
      'equipment': 'smith_machine, adjustable_bench',
      'animation_asset': 'lottie/bulgarian_split_squat.json',
      'exercise_type': 'compound',
      'form_cues':
          'Rear foot elevated on bench|Front foot far enough forward|Lower back knee toward floor|Front knee tracks over toe|Torso upright|Hardest exercise — go light',
      'common_mistakes':
          'Front foot too close|Leaning forward too much|Not going deep enough',
      'breathing_cue': 'Inhale lowering, exhale pushing up',
      'default_rest_seconds': 90,
      'is_compound': 1,
      'default_rpe_target': 7,
    },
    // 30 - Dumbbell Romanian Deadlift
    {
      'id': 30,
      'name': 'Dumbbell Romanian Deadlift',
      'muscle_primary': 'Hamstrings',
      'muscle_secondary': 'Glutes, Lower Back',
      'equipment': 'dumbbells',
      'animation_asset': 'lottie/db_rdl.json',
      'exercise_type': 'compound',
      'form_cues':
          'Same movement as barbell RDL|Dumbbells allow better range|Natural hand path|Push hips back|Keep slight knee bend|Feel hamstring stretch',
      'common_mistakes':
          'Same as barbell RDL|Dumbbells drifting forward',
      'breathing_cue': 'Inhale lowering, exhale driving up',
      'default_rest_seconds': 120,
      'is_compound': 1,
      'default_rpe_target': 7,
    },
    // 31 - Hanging Knee Raise (Oblique)
    {
      'id': 31,
      'name': 'Hanging Knee Raise (Oblique)',
      'muscle_primary': 'Obliques',
      'muscle_secondary': 'Lower Abs',
      'equipment': 'hanging_leg_raise_station',
      'animation_asset': 'lottie/hanging_knee_raise.json',
      'exercise_type': 'isolation',
      'form_cues':
          'Same setup as leg raise|Knees bent|Rotate knees to each side|Controlled movement|Feel obliques working',
      'common_mistakes':
          'Swinging|Not rotating enough|Going too fast',
      'breathing_cue': 'Exhale raising, inhale lowering',
      'default_rest_seconds': 60,
      'is_compound': 0,
      'default_rpe_target': 6,
    },
  ];

  static const List<Map<String, dynamic>> _workoutDays = [
    {
      'id': 1,
      'day_number': 1,
      'day_name': 'Monday',
      'workout_type': 'Push',
      'workout_label': 'PUSH DAY — Primary',
      'is_variation': 0,
    },
    {
      'id': 2,
      'day_number': 2,
      'day_name': 'Tuesday',
      'workout_type': 'Pull',
      'workout_label': 'PULL DAY — Primary',
      'is_variation': 0,
    },
    {
      'id': 3,
      'day_number': 3,
      'day_name': 'Wednesday',
      'workout_type': 'Legs',
      'workout_label': 'LEG DAY — Primary',
      'is_variation': 0,
    },
    {
      'id': 4,
      'day_number': 4,
      'day_name': 'Thursday',
      'workout_type': 'Push',
      'workout_label': 'PUSH DAY — Variation',
      'is_variation': 1,
    },
    {
      'id': 5,
      'day_number': 5,
      'day_name': 'Friday',
      'workout_type': 'Pull',
      'workout_label': 'PULL DAY — Variation',
      'is_variation': 1,
    },
    {
      'id': 6,
      'day_number': 6,
      'day_name': 'Saturday',
      'workout_type': 'Legs',
      'workout_label': 'LEG DAY — Variation',
      'is_variation': 1,
    },
  ];

  static const String _compoundWarmupJson =
      '[{"label":"Warm Up 1","pct":0.4,"reps":15},{"label":"Warm Up 2","pct":0.65,"reps":8}]';
  static const String _isolationWarmupJson =
      '[{"label":"Warm Up","pct":0.5,"reps":12}]';

  static List<Map<String, dynamic>> get _dayExercises => [
        // ===== DAY 1 (Monday — Push Primary) =====
        {
          'workout_day_id': 1,
          'exercise_id': 1,
          'order_index': 1,
          'target_sets': 3,
          'target_reps_min': 8,
          'target_reps_max': 10,
          'rest_seconds': 120,
          'recommended_start_weight': 35,
          'has_warmup': 1,
          'warmup_sets_json': _compoundWarmupJson,
        },
        {
          'workout_day_id': 1,
          'exercise_id': 2,
          'order_index': 2,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 12,
          'rest_seconds': 90,
          'recommended_start_weight': 10,
          'has_warmup': 1,
          'warmup_sets_json': _isolationWarmupJson,
        },
        {
          'workout_day_id': 1,
          'exercise_id': 3,
          'order_index': 3,
          'target_sets': 3,
          'target_reps_min': 12,
          'target_reps_max': 15,
          'rest_seconds': 60,
          'recommended_start_weight': 20,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 1,
          'exercise_id': 4,
          'order_index': 4,
          'target_sets': 3,
          'target_reps_min': 12,
          'target_reps_max': 15,
          'rest_seconds': 60,
          'recommended_start_weight': 6,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 1,
          'exercise_id': 5,
          'order_index': 5,
          'target_sets': 3,
          'target_reps_min': 12,
          'target_reps_max': 15,
          'rest_seconds': 60,
          'recommended_start_weight': 12,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 1,
          'exercise_id': 6,
          'order_index': 6,
          'target_sets': 2,
          'target_reps_min': 5,
          'target_reps_max': 15,
          'rest_seconds': 90,
          'recommended_start_weight': 0,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },

        // ===== DAY 2 (Tuesday — Pull Primary) =====
        {
          'workout_day_id': 2,
          'exercise_id': 13,
          'order_index': 1,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 12,
          'rest_seconds': 120,
          'recommended_start_weight': 30,
          'has_warmup': 1,
          'warmup_sets_json': _compoundWarmupJson,
        },
        {
          'workout_day_id': 2,
          'exercise_id': 14,
          'order_index': 2,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 12,
          'rest_seconds': 120,
          'recommended_start_weight': 30,
          'has_warmup': 1,
          'warmup_sets_json': _isolationWarmupJson,
        },
        {
          'workout_day_id': 2,
          'exercise_id': 15,
          'order_index': 3,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 12,
          'rest_seconds': 60,
          'recommended_start_weight': 16,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 2,
          'exercise_id': 16,
          'order_index': 4,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 12,
          'rest_seconds': 75,
          'recommended_start_weight': 15,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 2,
          'exercise_id': 17,
          'order_index': 5,
          'target_sets': 3,
          'target_reps_min': 12,
          'target_reps_max': 12,
          'rest_seconds': 60,
          'recommended_start_weight': 10,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 2,
          'exercise_id': 18,
          'order_index': 6,
          'target_sets': 2,
          'target_reps_min': 15,
          'target_reps_max': 20,
          'rest_seconds': 45,
          'recommended_start_weight': 10,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },

        // ===== DAY 3 (Wednesday — Legs Primary) =====
        {
          'workout_day_id': 3,
          'exercise_id': 24,
          'order_index': 1,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 12,
          'rest_seconds': 120,
          'recommended_start_weight': 30,
          'has_warmup': 1,
          'warmup_sets_json': _compoundWarmupJson,
        },
        {
          'workout_day_id': 3,
          'exercise_id': 25,
          'order_index': 2,
          'target_sets': 3,
          'target_reps_min': 12,
          'target_reps_max': 15,
          'rest_seconds': 75,
          'recommended_start_weight': 20,
          'has_warmup': 1,
          'warmup_sets_json': _isolationWarmupJson,
        },
        {
          'workout_day_id': 3,
          'exercise_id': 26,
          'order_index': 3,
          'target_sets': 3,
          'target_reps_min': 12,
          'target_reps_max': 15,
          'rest_seconds': 75,
          'recommended_start_weight': 15,
          'has_warmup': 1,
          'warmup_sets_json': _isolationWarmupJson,
        },
        {
          'workout_day_id': 3,
          'exercise_id': 27,
          'order_index': 4,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 12,
          'rest_seconds': 120,
          'recommended_start_weight': 35,
          'has_warmup': 1,
          'warmup_sets_json': _compoundWarmupJson,
        },
        {
          'workout_day_id': 3,
          'exercise_id': 28,
          'order_index': 5,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 15,
          'rest_seconds': 60,
          'recommended_start_weight': 0,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },

        // ===== DAY 4 (Thursday — Push Variation) =====
        {
          'workout_day_id': 4,
          'exercise_id': 7,
          'order_index': 1,
          'target_sets': 3,
          'target_reps_min': 8,
          'target_reps_max': 10,
          'rest_seconds': 120,
          'recommended_start_weight': 30,
          'has_warmup': 1,
          'warmup_sets_json': _compoundWarmupJson,
        },
        {
          'workout_day_id': 4,
          'exercise_id': 8,
          'order_index': 2,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 12,
          'rest_seconds': 90,
          'recommended_start_weight': 20,
          'has_warmup': 1,
          'warmup_sets_json': _compoundWarmupJson,
        },
        {
          'workout_day_id': 4,
          'exercise_id': 9,
          'order_index': 3,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 12,
          'rest_seconds': 90,
          'recommended_start_weight': 40,
          'has_warmup': 1,
          'warmup_sets_json': _compoundWarmupJson,
        },
        {
          'workout_day_id': 4,
          'exercise_id': 10,
          'order_index': 4,
          'target_sets': 3,
          'target_reps_min': 12,
          'target_reps_max': 15,
          'rest_seconds': 60,
          'recommended_start_weight': 6,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 4,
          'exercise_id': 11,
          'order_index': 5,
          'target_sets': 3,
          'target_reps_min': 12,
          'target_reps_max': 15,
          'rest_seconds': 60,
          'recommended_start_weight': 10,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 4,
          'exercise_id': 12,
          'order_index': 6,
          'target_sets': 2,
          'target_reps_min': 12,
          'target_reps_max': 15,
          'rest_seconds': 60,
          'recommended_start_weight': 8,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },

        // ===== DAY 5 (Friday — Pull Variation) =====
        {
          'workout_day_id': 5,
          'exercise_id': 19,
          'order_index': 1,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 12,
          'rest_seconds': 120,
          'recommended_start_weight': 30,
          'has_warmup': 1,
          'warmup_sets_json': _compoundWarmupJson,
        },
        {
          'workout_day_id': 5,
          'exercise_id': 20,
          'order_index': 2,
          'target_sets': 3,
          'target_reps_min': 8,
          'target_reps_max': 10,
          'rest_seconds': 120,
          'recommended_start_weight': 40,
          'has_warmup': 1,
          'warmup_sets_json': _compoundWarmupJson,
        },
        {
          'workout_day_id': 5,
          'exercise_id': 21,
          'order_index': 3,
          'target_sets': 3,
          'target_reps_min': 12,
          'target_reps_max': 15,
          'rest_seconds': 75,
          'recommended_start_weight': 15,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 5,
          'exercise_id': 22,
          'order_index': 4,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 12,
          'rest_seconds': 75,
          'recommended_start_weight': 12,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 5,
          'exercise_id': 23,
          'order_index': 5,
          'target_sets': 3,
          'target_reps_min': 12,
          'target_reps_max': 15,
          'rest_seconds': 60,
          'recommended_start_weight': 15,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 5,
          'exercise_id': 18,
          'order_index': 6,
          'target_sets': 2,
          'target_reps_min': 15,
          'target_reps_max': 20,
          'rest_seconds': 45,
          'recommended_start_weight': 10,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },

        // ===== DAY 6 (Saturday — Legs Variation) =====
        {
          'workout_day_id': 6,
          'exercise_id': 29,
          'order_index': 1,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 10,
          'rest_seconds': 90,
          'recommended_start_weight': 0,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 6,
          'exercise_id': 25,
          'order_index': 2,
          'target_sets': 3,
          'target_reps_min': 15,
          'target_reps_max': 20,
          'rest_seconds': 75,
          'recommended_start_weight': 17,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 6,
          'exercise_id': 26,
          'order_index': 3,
          'target_sets': 3,
          'target_reps_min': 12,
          'target_reps_max': 12,
          'rest_seconds': 75,
          'recommended_start_weight': 15,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 6,
          'exercise_id': 30,
          'order_index': 4,
          'target_sets': 3,
          'target_reps_min': 12,
          'target_reps_max': 12,
          'rest_seconds': 120,
          'recommended_start_weight': 20,
          'has_warmup': 1,
          'warmup_sets_json': _compoundWarmupJson,
        },
        {
          'workout_day_id': 6,
          'exercise_id': 31,
          'order_index': 5,
          'target_sets': 3,
          'target_reps_min': 15,
          'target_reps_max': 20,
          'rest_seconds': 60,
          'recommended_start_weight': 0,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
        {
          'workout_day_id': 6,
          'exercise_id': 28,
          'order_index': 6,
          'target_sets': 3,
          'target_reps_min': 10,
          'target_reps_max': 15,
          'rest_seconds': 60,
          'recommended_start_weight': 0,
          'has_warmup': 0,
          'warmup_sets_json': null,
        },
      ];
}
