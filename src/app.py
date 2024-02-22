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
        db = yaml.load(open('db.yaml'), Loader=yaml.FullLoader)
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
        goals = ','.join(user_details['goals'])  # Assuming goals is a list
        fitness_level = user_details['fitness_level']
        workout_days = user_details['workout_days']  # Assuming workout_days is a list of strings like ["Monday", "Wednesday"]

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        
        # Insert user into database
        cur.execute("INSERT INTO users(username, password, first_name, last_name, gender, date_of_birth, height_cm, weight_kg, activity_level, goals, fitness_level) VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", (username, password, first_name, last_name, gender, date_of_birth, height_cm, weight_kg, activity_level, goals, fitness_level,))
        user_id = cur.lastrowid
        
        # Insert workout days
        for day in workout_days:
            cur.execute("INSERT INTO user_workout_days(user_id, workout_day_id) SELECT %s, workout_day_id FROM workout_days WHERE day_of_week = %s", (user_id, day,))
        
        mysql.connection.commit()
        cur.close()
        
        return jsonify({"message": "Registration successful", "status": "success"}), 201


    @app.route('/profile/<username>', methods=['GET'])
    def get_user_profile(username):
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute("SELECT user_id, username, email, first_name, last_name, gender, date_of_birth, height_cm, weight_kg, activity_level, goals, fitness_level FROM users WHERE username = %s", (username,))
        user_info = cur.fetchone()
        
        if user_info:
            # Retrieve user's workout days using the user_id from the fetched user_info
            cur.execute("SELECT wd.day_of_week FROM workout_days wd JOIN user_workout_days uwd ON wd.workout_day_id = uwd.workout_day_id WHERE uwd.user_id = %s", (user_info['user_id'],))
            workout_days = [row['day_of_week'] for row in cur.fetchall()]
            user_info['workout_days'] = workout_days
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
        workout_days = data.get('workout_days')  # Assuming workout_days is provided as a list of strings

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Update basic metrics in users table
        cur.execute("""
            UPDATE users SET height_cm = %s, weight_kg = %s, 
            activity_level = %s, goals = %s, fitness_level = %s
            WHERE username = %s
            """, (height_cm, weight_kg, activity_level, goals, fitness_level, username))

        # Update workout days
        # First, get the user_id for the given username
        cur.execute("SELECT user_id FROM users WHERE username = %s", (username,))
        user_info = cur.fetchone()
        if user_info:
            user_id = user_info['user_id']
            # Clear existing workout days for the user
            cur.execute("DELETE FROM user_workout_days WHERE user_id = %s", (user_id,))

            # Insert new workout days
            for day in workout_days:
                cur.execute("""
                    INSERT INTO user_workout_days(user_id, workout_day_id) 
                    SELECT %s, workout_day_id FROM workout_days WHERE day_of_week = %s
                    """, (user_id, day))

        mysql.connection.commit()
        cur.close()

        return jsonify({"status": "success", "message": "Profile updated successfully"}), 200
    # Add more routes here for getting and setting user profile information
    return app
if __name__ == '__main__':
    app = create_app()
    app.run(debug=True)
