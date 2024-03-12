INSERT INTO users (username, password, first_name, last_name, gender, date_of_birth, height_cm, weight_kg, activity_level, goals, fitness_level)
VALUES ('testuser', 'testpassword', 'John', 'Doe', 'male', '1990-01-01', 180.00, 80.00, 'active', 'build muscle,lose weight', 'intermediate');
INSERT INTO user_conditions (user_id, condition_description)
VALUES (1, 'Type 2 Diabetes');
INSERT INTO daily_logs (user_id, date_logged)
VALUES (1, '2024-03-12');
INSERT INTO calorie_intake_details (log_id, calories, meal_type)
VALUES (1, 500, 'breakfast');
INSERT INTO exercise_records (log_id, exercise_type, duration_minutes, calories_burned)
VALUES (1, 'Running', 30, 300);
INSERT INTO body_metrics (log_id, height_cm, weight_kg)
VALUES (1, 180.00, 80.00);