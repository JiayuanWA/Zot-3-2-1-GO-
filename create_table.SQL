DROP DATABASE IF EXISTS `healthdb`;
CREATE DATABASE `healthdb`;
USE `healthdb`;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    gender ENUM('male', 'female', 'other') NOT NULL,
    date_of_birth DATE,
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    activity_level ENUM('sedentary', 'moderate', 'active', 'very active') NOT NULL,
    goals SET('build muscle', 'lose weight', 'improve cardio', 'better lifestyle', 'improve sleep quality', 'improve posture', 'increase flexibility', 'achieve mental clarity') NOT NULL,
    fitness_level ENUM('beginner', 'intermediate', 'advanced') NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE workout_days (
    workout_day_id INT AUTO_INCREMENT PRIMARY KEY,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL UNIQUE
);

CREATE TABLE user_workout_days (
    user_id INT,
    workout_day_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (workout_day_id) REFERENCES workout_days(workout_day_id),
    PRIMARY KEY (user_id, workout_day_id)
);

-- Retain the existing tables for body metrics, common conditions, user conditions, daily logs, calorie intake details, and exercise records
CREATE TABLE body_metrics (
    metric_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    date_recorded DATE,
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE common_conditions (
    condition_id INT AUTO_INCREMENT PRIMARY KEY,
    condition_name VARCHAR(255) NOT NULL,
    condition_type ENUM('illness', 'injury', 'other') NOT NULL,
    description TEXT,
    impact_on_exercise TEXT
);

CREATE TABLE user_conditions (
    uc_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    condition_id INT NULL,
    condition_name VARCHAR(255) NULL,
    severity ENUM('mild', 'moderate', 'severe'),
    start_usersuser_workout_daysusersdate DATE,
    end_date DATE,
    notes TEXT,
    FOREIGN KEY (userusers_id) REFERENCES users(user_id),
    FOREIGN KEY (condition_id) REFERENCES common_conditions(condition_id)
);

CREATE TABLE daily_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    date_logged DATE,
    total_calories INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE calorie_intake_details (
    intake_id INT AUTO_INCREMENT PRIMARY KEY,
    log_id INT,
    calories INT,
    meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack'),
    FOREIGN KEY (log_id) REFERENCES daily_logs(log_id)
);

CREATE TABLE exercise_records (
    exercise_id INT AUTO_INCREMENT PRIMARY KEY,
    log_id INT,
    exercise_type VARCHAR(255),
    duration_minutes INT,
    intensity ENUM('low', 'medium', 'high'),
    calories_burned INT,
    time_started TIME,
    FOREIGN KEY (log_id) REFERENCES daily_logs(log_id)
);