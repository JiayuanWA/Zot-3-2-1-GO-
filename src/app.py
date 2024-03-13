from datetime import date
from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re
import yaml
import csv
import openai 
import json  


def create_app(test_config=None):
    app = Flask(__name__, instance_relative_config=True)

    if test_config is None:
        # Load the instance config, if it exists, when not testing
        app.config.from_pyfile('config.py', silent=True)
        # Load database connection info from a secure location.
        with open('db.yaml', 'r') as file:
            db = yaml.load(file, Loader=yaml.FullLoader)
    else:
        # Load the test config if passed in
        app.config.update(test_config)
        db = test_config

    app.config['MYSQL_HOST'] = db['mysql_host']
    app.config['MYSQL_USER'] = db['mysql_user']
    app.config['MYSQL_PASSWORD'] = db['mysql_password']
    app.config['MYSQL_DB'] = db['mysql_db']

    mysql = MySQL(app)

    @app.route('/')
    def hello():
        return "<h1 style='color:blue'>Hello World!</h1>"
    
    @app.route('/login', methods=['POST'])
    def login():
        username = request.json['username']
        password = request.json['password']

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute("SELECT * FROM users WHERE username = %s AND password = %s", (username, password,))
        user = cur.fetchone()
        cur.close()

        if user:
            return jsonify({"message": "Login successful", "status": "success", "user": user}), 200
        else:
            return jsonify({"message": "Login failed", "status": "fail"}), 401

    @app.route('/register', methods=['POST'])
    def register():
        # Extract user details from the request
        user_details = request.json
        username = user_details['username']
        password = user_details['password']
        first_name = user_details['first_name']
        last_name = user_details['last_name']
        gender = user_details['gender']
        date_of_birth = user_details['date_of_birth']
        height_cm = user_details['height_cm']
        weight_kg = user_details['weight_kg']
        activity_level = user_details['activity_level']
        goals = ','.join(user_details['goals'])  
        fitness_level = user_details['fitness_level']

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute("SELECT * FROM users WHERE username = %s", (username,))
        if cur.fetchone():
        # Username already exists
            cur.close()
            return jsonify({"message": "Username already exists", "status": "fail"}), 400
        # Insert user into database
        cur.execute("INSERT INTO users(username, password, first_name, last_name, gender, date_of_birth, height_cm, weight_kg, activity_level, goals, fitness_level) VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", (username, password, first_name, last_name, gender, date_of_birth, height_cm, weight_kg, activity_level, goals, fitness_level,))
        user_id = cur.lastrowid
        mysql.connection.commit()
        cur.close()
        
        return jsonify({"message": "Registration successful", "status": "success"}), 201


    @app.route('/profile/<username>', methods=['GET'])
    def get_user_profile(username):
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute("SELECT user_id, username, email, first_name, last_name, gender, date_of_birth, height_cm, weight_kg, activity_level, goals, fitness_level FROM users WHERE username = %s", (username,))
        user_info = cur.fetchone()
        
        if user_info:
            cur.close()
            return jsonify({"status": "success", "user_info": user_info}), 200
        else:
            cur.close()
            return jsonify({"status": "fail", "message": "User not found"}), 404

    @app.route('/profile/update', methods=['POST'])
    def update_user_profile():
        # Extract data from request
        data = request.json
        username = data['username']
        height_cm = data.get('height_cm')
        weight_kg = data.get('weight_kg')
        activity_level = data.get('activity_level')
        goals = ','.join(data['goals']) if 'goals' in data else None  # Assuming goals is provided as a list
        fitness_level = data.get('fitness_level')

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Update basic metrics in users table
        cur.execute("""
            UPDATE users SET height_cm = %s, weight_kg = %s, 
            activity_level = %s, goals = %s, fitness_level = %s
            WHERE username = %s
            """, (height_cm, weight_kg, activity_level, goals, fitness_level, username))
        cur.execute("SELECT user_id FROM users WHERE username = %s", (username,))
    

        mysql.connection.commit()
        cur.close()

        return jsonify({"status": "success", "message": "Profile updated successfully"}), 200
    # Add more routes here for getting and setting user profile information
    @app.route('/initialize_daily_log', methods=['POST'])
    def initialize_daily_log():
        data = request.json
        username = data['username']
        date = data.get('date', None)  # Use the current date if not provided

        # If no date is provided, use the current date
        if not date:
            from datetime import datetime
            date = datetime.now().strftime('%Y-%m-%d')

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Verify user exists and get user_id
        cur.execute("SELECT user_id FROM users WHERE username = %s", (username,))
        user = cur.fetchone()
        if not user:
            cur.close()
            return jsonify({"message": "User not found", "status": "fail"}), 404
        user_id = user['user_id']

        # Check if a daily log for this date already exists
        cur.execute("SELECT log_id FROM daily_logs WHERE user_id = %s AND date_logged = %s", (user_id, date))
        log = cur.fetchone()

        if not log:
            # Insert a new daily log if it doesn't exist
            cur.execute("INSERT INTO daily_logs (user_id, date_logged) VALUES (%s, %s)", (user_id, date))
            mysql.connection.commit()
            message = "Daily log initialized successfully"
        else:
            message = "Daily log already exists for this date"

        cur.close()
        return jsonify({"message": message, "status": "success"}), 200

    # Assuming this function finds or creates a log entry and returns its log_id
    def get_or_create_log_id(user_id, date_logged):
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute("SELECT log_id FROM daily_logs WHERE user_id = %s AND date_logged = %s", (user_id, date_logged))
        log = cur.fetchone()
        if log:
            return log['log_id']
        else:
            # Insert a new daily log if it doesn't exist
            cur.execute("INSERT INTO daily_logs (user_id, date_logged) VALUES (%s, %s)", (user_id, date_logged))
            mysql.connection.commit()
            return cur.lastrowid  # Return the newly created log_id

    @app.route('/log/calorie_intake', methods=['POST'])
    def log_calorie_intake():
        data = request.json
        username = data['username']
        date_logged = data['date_logged']
        meals = data['meals']

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Fetch user_id using username
        cur.execute("SELECT user_id FROM users WHERE username = %s", (username,))
        user = cur.fetchone()
        if not user:
            return jsonify({"message": "User not found", "status": "fail"}), 404

        log_id = get_or_create_log_id(user['user_id'], date_logged)
        if not log_id:
            return jsonify({"message": "Daily log not found", "status": "fail"}), 404

        # Insert calorie intake logs using log_id
        for meal in meals:
            cur.execute("INSERT INTO calorie_intake_details (log_id, calories, meal_type) VALUES (%s, %s, %s)",
                        (log_id, meal['calories'], meal['meal_type']))

        mysql.connection.commit()
        return jsonify({"message": "Calorie intake logged successfully"}), 201

    @app.route('/log/exercise', methods=['POST'])
    def log_exercise():
        data = request.json
        username = data['username']
        date_logged = data['date_logged']
        exercises = data['exercises']

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Fetch user_id using username
        cur.execute("SELECT user_id FROM users WHERE username = %s", (username,))
        user = cur.fetchone()
        if not user:
            return jsonify({"message": "User not found", "status": "fail"}), 404
    
        log_id = get_or_create_log_id(user['user_id'], date_logged)

        # Insert exercise logs using log_id
        for exercise in exercises:
            cur.execute("""
                INSERT INTO exercise_records (log_id, exercise_type, duration_minutes, calories_burned) 
                VALUES (%s, %s, %s, %s)
                """, (log_id, exercise['type'], exercise['duration'], exercise['calories_burned']))

        mysql.connection.commit()
        return jsonify({"message": "Exercise logged successfully"}), 201


    @app.route('/log/body_metrics', methods=['POST'])
    def log_body_metrics():
        data = request.json
        username = data['username']
        date_logged = data['date_logged']
        metrics = data['metrics']

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Fetch user_id using username
        cur.execute("SELECT user_id FROM users WHERE username = %s", (username,))
        user = cur.fetchone()
        if not user:
            return jsonify({"message": "User not found", "status": "fail"}), 404
        log_id = get_or_create_log_id(user['user_id'], date_logged)
        # Extract height and weight from metrics
        height = metrics.get('height_cm')
        weight = metrics.get('weight_kg')

        # Insert or update height and weight in body_metrics table
        if height and weight:
            cur.execute("""
                INSERT INTO body_metrics (log_id, height_cm, weight_kg)
                VALUES (%s, %s, %s)
                ON DUPLICATE KEY UPDATE
                height_cm = VALUES(height_cm),
                weight_kg = VALUES(weight_kg)
                """, (log_id, height, weight))

            # Update user's latest height and weight in the users table
            cur.execute("UPDATE users SET height_cm = %s, weight_kg = %s WHERE user_id = %s", (height, weight, user['user_id']))

        mysql.connection.commit()
        cur.close()

        return jsonify({"message": "Body metrics logged successfully"}), 201

    def get_calorie_intake_by_date(user_id):
        query = """
        SELECT dl.date_logged, SUM(cid.calories) as total_calories
        FROM daily_logs dl
        JOIN calorie_intake_details cid ON dl.log_id = cid.log_id
        WHERE dl.user_id = %s
        GROUP BY dl.date_logged
        ORDER BY dl.date_logged;
        """
        cur = mysql.connection.cursor()
        cur.execute(query, (user_id,))
        results = cur.fetchall()
        cur.close()
        return results


    def get_exercise_records_by_date(user_id):
        query = """
        SELECT dl.date_logged, er.exercise_type, er.duration_minutes, er.calories_burned
        FROM daily_logs dl
        JOIN exercise_records er ON dl.log_id = er.log_id
        WHERE dl.user_id = %s
        ORDER BY dl.date_logged, er.time_started;
        """
        cur = mysql.connection.cursor()
        cur.execute(query, (user_id,))
        results = cur.fetchall()
        cur.close()
        return results

    def get_body_metric_changes_by_date(user_id):
        query = """
        SELECT dl.date_logged, bm.height_cm, bm.weight_kg
        FROM daily_logs dl
        JOIN body_metrics bm ON dl.log_id = bm.log_id
        WHERE dl.user_id = %s
        ORDER BY dl.date_logged;
        """
        cur = mysql.connection.cursor()
        cur.execute(query, (user_id,))
        results = cur.fetchall()
        cur.close()
        return results
    def get_user_id_by_username(username):
        query = "SELECT user_id FROM users WHERE username = %s"
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute(query, (username,))
        user = cur.fetchone()
        cur.close()
        return user['user_id'] if user else None


    @app.route('/get_calorie_intake/<username>', methods=['GET'])
    def get_calorie_intake_for_username(username):
        # Resolve user_id from username
        user_id = get_user_id_by_username(username)
        if not user_id:
            return jsonify({"message": "User not found"}), 404
        calorie_intake = get_calorie_intake_by_date(user_id)
        return jsonify(calorie_intake)

    @app.route('/get_exercise_records/<username>', methods=['GET'])
    def get_exercise_records_for_username(username):
        # Resolve user_id from username
        user_id = get_user_id_by_username(username)
        if not user_id:
            return jsonify({"message": "User not found"}), 404
        exercise_records = get_exercise_records_by_date(user_id)
        return jsonify(exercise_records)


    @app.route('/get_body_metrics/<username>', methods=['GET'])
    def get_body_metrics_for_username(username):
        # Resolve user_id from username
        user_id = get_user_id_by_username(username)
        if not user_id:
            return jsonify({"message": "User not found"}), 404
        body_metrics = get_body_metric_changes_by_date(user_id)
        return jsonify(body_metrics)


    @app.route('/get_exercise_info/<username>', methods=['GET'])
    def get_exercise_info(username):
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute('SELECT weight_kg FROM users WHERE username = %s', (username,))
        user = cur.fetchone()
        if user:
            weight_kg = user['weight_kg']
            exercise_data = []
            with open('exercise_dataset.csv', mode ='r') as file:
                csvFile = csv.DictReader(file)
                for lines in csvFile:
                    activity = lines['Activity, Exercise or Sport (1 hour)']
                    calories = float(lines['Calories per kg']) * float(weight_kg)
                    exercise_data.append({'activity': activity, 'calories': calories})
            return jsonify(exercise_data)
        else:
            return jsonify({'message': 'User not found'}), 404

    def calculate_basic_calories_burned(height, weight, age, gender, activity_level):
        activity_factors = {
            'sedentary': 1.2,
            'light': 1.375,
            'moderate': 1.55,
            'active': 1.725,
            'very active': 1.9
        }
        if gender == 'male':
            bmr = 88.362 + (13.397 * float(weight)) + (4.799 * float(height)) - (5.677 * float(age))* float(activity_factors.get(activity_level, 1))
        else:
            bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age)* activity_factors.get(activity_level, 1)
        return bmr

    def calculate_age(born):
        today = date.today()
        return today.year - born.year - ((today.month, today.day) < (born.month, born.day))

    @app.route('/add_user_condition', methods=['POST'])
    def add_user_condition():
        data = request.json
        username = data['username']
        user_id = get_user_id_by_username(username)
        condition_description = data['condition_description']
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        try:
            cur.execute("INSERT INTO user_conditions(user_id, condition_description) VALUES(%s, %s)", (user_id, condition_description,))
            mysql.connection.commit()
            return jsonify({"message": "User condition added successfully", "status": "success"}), 200
        except Exception as e:
            return jsonify({"message": str(e), "status": "fail"}), 400
        finally:
            cur.close()

    @app.route('/delete_user_condition_by_description', methods=['POST'])
    def delete_user_condition_by_description():
        data = request.json
        username = data['username']
        condition_description = data['condition_description']

        # Resolve user_id from username
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute("SELECT user_id FROM users WHERE username = %s", (username,))
        user = cur.fetchone()

        if not user:
            cur.close()
            return jsonify({"message": "User not found", "status": "fail"}), 404

        user_id = user['user_id']

        try:
            # Delete the condition based on user_id and condition_description
            cur.execute("DELETE FROM user_conditions WHERE user_id = %s AND condition_description = %s", (user_id, condition_description,))
            mysql.connection.commit()

            if cur.rowcount == 0:
                return jsonify({"message": "User condition not found or already deleted", "status": "fail"}), 404

            return jsonify({"message": "User condition deleted successfully", "status": "success"}), 200
        except Exception as e:
            return jsonify({"message": str(e), "status": "fail"}), 400
        finally:
            cur.close()

            
    @app.route('/get_recommendation', methods=['POST'])
    def get_user_fitness_info():
        data = request.json
        username = data['username']
        date = data['date']
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    
        # Fetch the user details
        cur.execute("SELECT date_of_birth, gender, goals, fitness_level, activity_level, height_cm, weight_kg  FROM users WHERE username = %s", (username,))
        user_info = cur.fetchone()
        if not user_info:
            return jsonify({"message": "User not found"}), 404

        
        gender = user_info['gender']
        activity_level = user_info['activity_level']
        height_cm = user_info['height_cm']
        weight_kg = user_info['weight_kg']
        date_of_birth = user_info['date_of_birth']

        cur.execute("SELECT condition_description FROM user_conditions WHERE user_id = (SELECT user_id FROM users WHERE username = %s)", (username,))
        user_conditions = cur.fetchall()
        conditions_list = [condition['condition_description'] for condition in user_conditions]
        conditions_str = ", ".join(conditions_list)
        
        # calculate age
        age = calculate_age(date_of_birth)

        # Fetch daily logs for the date
        cur.execute("""
            SELECT calories_burned
            FROM daily_logs
            JOIN exercise_records ON daily_logs.log_id = exercise_records.log_id
            WHERE user_id = (SELECT user_id FROM users WHERE username = %s) AND date_logged = %s
            """, (username, date))
        daily_exercise_logs = cur.fetchall()
        # calculate exercise burned calorie 
        exercise_calorie = sum(log['calories_burned'] for log in daily_exercise_logs)
        cur.execute("""
            SELECT calories
            FROM daily_logs
            JOIN calorie_intake_details ON daily_logs.log_id = calorie_intake_details.log_id
            WHERE user_id = (SELECT user_id FROM users WHERE username = %s) AND date_logged = %s
            """, (username, date))
        daily_intake_logs = cur.fetchall()
        # calculate intake calorie
        intake_calorie = sum(log['calories'] for log in daily_intake_logs)

        daily_BMR = calculate_basic_calories_burned(height_cm, weight_kg, age, gender, activity_level)

        # get all name for activity
        exercises = []
        # Read the CSV file to match the user's weight with the calories burned per kg for the exercises performed
        with open('exercise_dataset.csv', mode='r') as csvfile:
            csv_reader = csv.DictReader(csvfile)
            for row in csv_reader:
                exercises.append(row['Activity, Exercise or Sport (1 hour)'])

        openai.api_key = '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'
        # Construct the string to ask an AI for a fitness plan
        ai_query = f"Consider below circumstances, Goal: {user_info['goals']}, Fitness Level: {user_info['fitness_level']}, " \
                   f"Today's Intake Calories: {intake_calorie}, " \
                   f"Today's Exercise Calories: {exercise_calorie}, BMR: {daily_BMR}, "\
                   f"Conditions: {conditions_str}, "\
                   f"I want you to choose from the following exercise and choose 10 exercises, and gives out recommended duration for rest of my day in json format in list called exercise_list with name and duration only: "\
                   f"exercise list: {exercises}"


        messages = [ {"role": "system", "content": "You are a intelligent assistant."} ]
        messages.append( 
            {"role": "user", "content": ai_query}, 
        ) 
        chat = openai.ChatCompletion.create( 
            model="gpt-4-turbo-preview", messages=messages 
        )
        reply = chat.choices[0].message.content
        try:
            # Find the JSON substring within the reply
            json_str_start = reply.find('{')
            json_str_end = reply.rfind('}') + 1
            json_str = reply[json_str_start:json_str_end]

            # Parse the JSON string into a Python dictionary
            json_data = json.loads(json_str)
            print(json_data)
            return jsonify(json_data), 201
        except (ValueError, json.JSONDecodeError) as e:
            # Handle cases where JSON parsing fails
            return jsonify({"error": "Failed to parse AI reply into JSON", "detail": str(e)}), 400

    @app.route('/get_conditions/<username>', methods=['GET'])
    def get_conditions(username):
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        
        # Fetch user_id using username
        cur.execute("SELECT user_id FROM users WHERE username = %s", (username,))
        user = cur.fetchone()
        
        if not user:
            cur.close()
            return jsonify({"message": "User not found", "status": "fail"}), 404

        user_id = user['user_id']

        try:
            # Fetch all conditions for the user_id
            cur.execute("SELECT uc_id, condition_description FROM user_conditions WHERE user_id = %s", (user_id,))
            conditions = cur.fetchall()

            return jsonify({"message": "Conditions retrieved successfully", "status": "success", "conditions": conditions}), 200
        except Exception as e:
            return jsonify({"message": str(e), "status": "fail"}), 400
        finally:
            cur.close()

    def get_calorie_burn_rate(exercise_name, weight_kg):
        with open('exercise_dataset.csv', mode='r') as csvfile:
            csv_reader = csv.DictReader(csvfile)
            for row in csv_reader:
                print(row['Activity, Exercise or Sport (1 hour)'])
                if row['Activity, Exercise or Sport (1 hour)'] == exercise_name:
                    # Assuming the CSV contains a column for Calories per kg
                    # and the exercise matches exactly (consider implementing a more flexible search)
                    calories_per_kg = float(row['Calories per kg'])
                    return calories_per_kg * float(weight_kg)
        return None


    @app.route('/calculate_calories', methods=['POST'])
    def calculate_calories():
        data = request.json
        username = data['username']
        exercise_name = data['exercise_name']
        duration_minutes = data['duration_minutes']
        
        # Fetch user's weight
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute("SELECT weight_kg FROM users WHERE username = %s", (username,))
        user = cur.fetchone()
        cur.close()

        if not user:
            return jsonify({"message": "User not found", "status": "fail"}), 404
        
        weight_kg = user['weight_kg']
        calorie_burn_rate = get_calorie_burn_rate(exercise_name, weight_kg)
        
        if calorie_burn_rate is None:
            return jsonify({"message": "Exercise not found", "status": "fail"}), 404

        calories_burned = calorie_burn_rate * (duration_minutes / 60)
        
        return jsonify({
            "message": "Calories calculated successfully",
            "status": "success",
            "calories_burned": calories_burned
        }), 200

    @app.route('/list_exercises/<username>', methods=['GET'])
    def list_exercises(username):
        # Fetch user's weight from the database
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute("SELECT weight_kg FROM users WHERE username = %s", (username,))
        user = cur.fetchone()
        cur.close()

        if not user:
            return jsonify({"message": "User not found", "status": "fail"}), 404

        weight_kg = user['weight_kg']

        # Initialize a list to hold exercise data
        exercise_data = []

        # Parse the CSV to calculate calories burned for each exercise
        try:
            with open('exercise_dataset.csv', mode='r') as csvfile:
                reader = csv.DictReader(csvfile)
                for row in reader:
                    exercise_name = row['Activity, Exercise or Sport (1 hour)']
                    # Assuming 'Calories per kg per hour' is the correct column name, adjust as necessary
                    calories_burned_per_hour = float(row['Calories per kg']) * float(weight_kg)
                    exercise_data.append({
                        "exercise_name": exercise_name,
                        "calories_burned_per_hour": calories_burned_per_hour
                    })

            return jsonify({
                "message": "Exercise list fetched successfully",
                "status": "success",
                "exercises": exercise_data
            }), 200
        except Exception as e:
            return jsonify({"message": str(e), "status": "fail"}), 500
    return app


app = create_app()
    
    
if __name__ == '__main__':
    
    app.run(debug=True)
