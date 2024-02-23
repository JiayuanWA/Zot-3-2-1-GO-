from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re
import yaml

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
        SELECT dl.date_logged, er.exercise_type, er.duration_minutes, er.intensity, er.calories_burned
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
        cur = mysql.connection.cursor()
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


    return app



    
    
if __name__ == '__main__':
    app = create_app()
    app.run(debug=True)
