CREATE TABLE IF NOT EXISTS "tag" (
    "id" INTEGER,
    "mainTag" INTEGER,
    "fromApp" INTEGER,
    "name" TEXT NOT NULL,
    "code" TEXT,
    "mainTagId" INTEGER,
    "color" INTEGER NOT NULL,
    "deletedAt" INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);

/* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (999, 0, 0, 'dummy', 'dummy', NULL, 0); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (1, 1, 1, 'Leg', 'Leg', NULL, 4294922834); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (2, 1, 1, 'Back', 'Back', NULL, 4294918273); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (3, 1, 1, 'Chest', 'Chest', NULL, 4292886779); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (4, 1, 1, 'Shoulders', 'Shoulders', NULL, 4285132974); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (5, 1, 1, 'Arms', 'Arms', NULL, 4279828479); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (6, 1, 1, 'Abs', 'Abs', NULL, 4294929984); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (7, 1, 1, 'Cardio', 'Cardio', NULL, 4294945600); /* BREAK */

INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (100, 0, 1, 'Quads', 'Quads', 1, (SELECT color FROM "tag" WHERE id = 1)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (101, 0, 1, 'Hamstrings', 'Hamstrings', 1, (SELECT color FROM "tag" WHERE id = 1)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (102, 0, 1, 'Glutes', 'Glutes', 1, (SELECT color FROM "tag" WHERE id = 1)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (103, 0, 1, 'Calves', 'Calves', 1, (SELECT color FROM "tag" WHERE id = 1)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (104, 0, 1, 'Traps', 'Traps', 2, (SELECT color FROM "tag" WHERE id = 2)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (105, 0, 1, 'Lats', 'Lats', 2, (SELECT color FROM "tag" WHERE id = 2)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (106, 0, 1, 'Lower Back', 'LowerBack', 2, (SELECT color FROM "tag" WHERE id = 2)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (107, 0, 1, 'Pectoralis Major', 'PectoralisMajor', 3, (SELECT color FROM "tag" WHERE id = 3)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (108, 0, 1, 'Pectoralis Minor', 'PectoralisMinor', 3, (SELECT color FROM "tag" WHERE id = 3)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (109, 0, 1, 'Delts', 'Delts', 4, (SELECT color FROM "tag" WHERE id = 4)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (110, 0, 1, 'Rotator Cuff', 'RotatorCuff', 4, (SELECT color FROM "tag" WHERE id = 4)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (111, 0, 1, 'Biceps', 'Biceps', 5, (SELECT color FROM "tag" WHERE id = 5)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (112, 0, 1, 'Triceps', 'Triceps', 5, (SELECT color FROM "tag" WHERE id = 5)); /* BREAK */
INSERT OR IGNORE INTO "tag" (id, mainTag, fromApp, name, code, mainTagId, color) VALUES (113, 0, 1, 'Forearms', 'Forearms', 5, (SELECT color FROM "tag" WHERE id = 5)); /* BREAK */

DELETE FROM tag WHERE id = 999;
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "code" TEXT,
    "type" TEXT,
    "tagId" INTEGER,
    "fromApp" INTEGER,
    "deletedAt" INTEGER,

    FOREIGN KEY ("tagId") REFERENCES "tag" ("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (999, 1, 'dummy', 'dummy', NULL, NULL); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (1, 1, 'Squat', 'Squat', 'repsAndWeight', 100); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (2, 1, 'Lunge', 'Lunge', 'repsAndWeight', 100); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (3, 1, 'Leg Press', 'LegPress', 'repsAndWeight', 100); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (4, 1, 'Leg Extension', 'LegExtension', 'repsAndWeight', 100); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (5, 1, 'Deadlift', 'Deadlift', 'repsAndWeight', 101); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (6, 1, 'Romanian Deadlift', 'RomanianDeadlift', 'repsAndWeight', 101); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (7, 1, 'Leg Curl', 'LegCurl', 'repsAndWeight', 101); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (8, 1, 'Hip Thrust', 'HipThrust', 'repsAndWeight', 102); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (9, 1, 'Glute Bridge', 'GluteBridge', 'repsAndWeight', 102); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (10, 1, 'Bulgarian Split Squat', 'BulgarianSplitSquat', 'repsAndWeight', 102); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (11, 1, 'Calf Raise', 'CalfRaise', 'repsAndWeight', 103); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (12, 1, 'Shrug', 'Shrug', 'repsAndWeight', 104); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (13, 1, 'Upright Row', 'UprightRow', 'repsAndWeight', 104); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (14, 1, 'Pull-Up', 'PullUp', 'reps', 105); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (15, 1, 'Lat Pulldown', 'LatPulldown', 'repsAndWeight', 105); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (16, 1, 'Row', 'Row', 'repsAndWeight', 105); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (18, 1, 'Hyperextension', 'Hyperextension', 'repsAndWeight', 106); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (19, 1, 'Bench Press', 'BenchPress', 'repsAndWeight', 107); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (20, 1, 'Push-Up', 'PushUp', 'reps', 107); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (21, 1, 'Chest Fly', 'ChestFly', 'repsAndWeight', 107); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (22, 1, 'Chest Dip', 'ChestDip', 'repsAndWeight', 108); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (23, 1, 'Shoulder Press', 'ShoulderPress', 'repsAndWeight', 109); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (24, 1, 'Lateral Raise', 'LateralRaise', 'repsAndWeight', 109); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (25, 1, 'Front Raise', 'FrontRaise', 'repsAndWeight', 109); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (26, 1, 'Shoulder ER/IR', 'ShoulderERIR', 'repsAndWeight', 110); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (27, 1, 'Bicep Curl', 'BicepCurl', 'repsAndWeight', 111); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (28, 1, 'Hammer Curl', 'HammerCurl', 'repsAndWeight', 111); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (29, 1, 'Tricep Dip', 'TricepDip', 'repsAndWeight', 112); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (30, 1, 'Tricep Extension', 'TricepExtension', 'repsAndWeight', 112); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (31, 1, 'Wrist Curl', 'WristCurl', 'repsAndWeight', 113); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (32, 1, 'Reverse Wrist Curl', 'ReverseWristCurl', 'repsAndWeight', 113); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (33, 1, 'Plank', 'Plank', 'time', 6); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (34, 1, 'Sit-up', 'Situp', 'reps', 6); /* BREAK */

INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (35, 1, 'Treadmill', 'Treadmill', 'time', 7); /* BREAK */
INSERT OR IGNORE INTO "exercise" (id, fromApp, name, code, type, tagId) VALUES (36, 1, 'Bike', 'Bike', 'time', 7); /* BREAK */


DELETE FROM exercise WHERE id = 999;
/* BREAK */

CREATE TABLE IF NOT EXISTS "training_template" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "deletedAt" INTEGER,

	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "training_template_note" (
    "id" INTEGER,
    "trainingTemplateId" INTEGER NOT NULL,
    "note" TEXT,
    FOREIGN KEY ("trainingTemplateId") REFERENCES "training_template" ("id")  ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
)
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_group_training_template" (
    "id" INTEGER,
    "order" INTEGER NOT NULL,
    "trainingTemplateId" INTEGER NOT NULL,
    "groupType" TEXT NOT NULL,
    FOREIGN KEY ("trainingTemplateId") REFERENCES "training_template" ("id")  ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_training_template" (
    "id" INTEGER,
    "order" INTEGER NOT NULL,
    "exerciseGroupTrainingTemplateId" INTEGER NOT NULL,
    "exerciseId" INTEGER NOT NULL,
    FOREIGN KEY ("exerciseGroupTrainingTemplateId") REFERENCES "exercise_group_training_template" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("exerciseId") REFERENCES "exercise" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_group_training_template" (
    "id" INTEGER,
    "order" INTEGER NOT NULL,
    "exerciseTrainingTemplateId" INTEGER NOT NULL,
    "groupType" TEXT NOT NULL,
    FOREIGN KEY ("exerciseTrainingTemplateId") REFERENCES "exercise_training_template" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_training_template" (
    "id" INTEGER,
    "order" INTEGER NOT NULL,
    "exerciseSetGroupTrainingTemplateId" INTEGER NOT NULL,
    "exerciseType" TEXT NOT NULL,
    FOREIGN KEY ("exerciseSetGroupTrainingTemplateId") REFERENCES "exercise_set_group_training_template" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_meta_reps_training_template" (
    "id" INTEGER,
    "exerciseSetTrainingTemplateId" INTEGER NOT NULL,
    "reps" INTEGER,
    FOREIGN KEY ("exerciseSetTrainingTemplateId") REFERENCES "exercise_set_training_template" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_meta_reps_and_weight_training_template" (
    "id" INTEGER,
    "exerciseSetTrainingTemplateId" INTEGER NOT NULL,
    "reps" INTEGER NOT NULL,
    "weight" REAl NOT NULL,
    "weightUnit" TEXT NOT NULL,
    FOREIGN KEY ("exerciseSetTrainingTemplateId") REFERENCES "exercise_set_training_template" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_time_training_template" (
    "id" INTEGER,
    "exerciseSetTrainingTemplateId" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    FOREIGN KEY ("exerciseSetTrainingTemplateId") REFERENCES "exercise_set_training_template" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_distance_training_template" (
    "id" INTEGER,
    "exerciseSetTrainingTemplateId" INTEGER NOT NULL,
    "distance" REAL NOT NULL,
    "unit" TEXT NOT NULL,
    FOREIGN KEY ("exerciseSetTrainingTemplateId") REFERENCES "exercise_set_training_template" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_time_and_distance_training_template" (
    "id" INTEGER,
    "exerciseSetTrainingTemplateId" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    "distance" REAL NOT NULL,
    "unit" TEXT NOT NULL,
    FOREIGN KEY ("exerciseSetTrainingTemplateId") REFERENCES "exercise_set_training_template" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */



CREATE TABLE IF NOT EXISTS "training_session" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "trainingTemplateId" INTEGER NULL,
    "duration" INTEGER NOT NULL,
    "date" INTEGER NOT NULL,
    "order" TEXT,
    "syncId" TEXT,
    FOREIGN KEY ("trainingTemplateId") REFERENCES "training_session" ("id")  ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);

/* BREAK */

CREATE TRIGGER IF NOT EXISTS set_default_order_value
AFTER INSERT ON "training_session"
BEGIN
    UPDATE "training_session"
    SET "order" = CAST("date" AS TEXT) || '_' || NEW.id
    WHERE "id" = NEW.id;
END;
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_group_training_session" (
    "id" INTEGER,
    "order" INTEGER NOT NULL,
    "trainingSessionId" INTEGER NOT NULL,
    "groupType" TEXT NOT NULL,
    FOREIGN KEY ("trainingSessionId") REFERENCES "training_session" ("id")  ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_training_session" (
    "id" INTEGER,
    "order" INTEGER NOT NULL,
    "exerciseGroupTrainingSessionId" INTEGER NOT NULL,
    "exerciseId" INTEGER NOT NULL,
    FOREIGN KEY ("exerciseGroupTrainingSessionId") REFERENCES "exercise_group_training_session" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("exerciseId") REFERENCES "exercise" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_group_training_session" (
    "id" INTEGER,
    "order" INTEGER NOT NULL,
    "exerciseTrainingSessionId" INTEGER NOT NULL,
    "groupType" TEXT NOT NULL,
    FOREIGN KEY ("exerciseTrainingSessionId") REFERENCES "exercise_training_session" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_training_session" (
    "id" INTEGER,
    "order" INTEGER NOT NULL,
    "exerciseSetGroupTrainingSessionId" INTEGER NOT NULL,
    "exerciseType" TEXT NOT NULL,
    "done" INTEGER NOT NULL,
    FOREIGN KEY ("exerciseSetGroupTrainingSessionId") REFERENCES "exercise_set_group_training_session" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_meta_reps_training_session" (
    "id" INTEGER,
    "exerciseSetTrainingSessionId" INTEGER NOT NULL,
    "reps" INTEGER,
    FOREIGN KEY ("exerciseSetTrainingSessionId") REFERENCES "exercise_set_training_session" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_meta_reps_and_weight_training_session" (
    "id" INTEGER,
    "exerciseSetTrainingSessionId" INTEGER NOT NULL,
    "reps" INTEGER NOT NULL,
    "weight" REAl NOT NULL,
    "weightUnit" TEXT NOT NULL,
    FOREIGN KEY ("exerciseSetTrainingSessionId") REFERENCES "exercise_set_training_session" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_time_training_session" (
    "id" INTEGER,
    "exerciseSetTrainingSessionId" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    FOREIGN KEY ("exerciseSetTrainingSessionId") REFERENCES "exercise_set_training_session" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_distance_training_session" (
    "id" INTEGER,
    "exerciseSetTrainingSessionId" INTEGER NOT NULL,
    "distance" REAL NOT NULL,
    "unit" TEXT NOT NULL,
    FOREIGN KEY ("exerciseSetTrainingSessionId") REFERENCES "exercise_set_training_session" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "exercise_set_time_and_distance_training_session" (
    "id" INTEGER,
    "exerciseSetTrainingSessionId" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    "distance" REAL NOT NULL,
    "unit" TEXT NOT NULL,
    FOREIGN KEY ("exerciseSetTrainingSessionId") REFERENCES "exercise_set_training_session" ("id") ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
/* BREAK */

CREATE TABLE IF NOT EXISTS "training_session_note" (
    "id" INTEGER,
    "trainingSessionId" INTEGER NOT NULL,
    "note" TEXT,
    FOREIGN KEY ("trainingSessionId") REFERENCES "training_session" ("id")  ON DELETE CASCADE,
	PRIMARY KEY("id" AUTOINCREMENT)
)
/* BREAK */
