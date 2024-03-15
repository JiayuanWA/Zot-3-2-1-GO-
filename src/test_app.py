import unittest
from app import create_app
from flask_mysqldb import MySQL
import yaml

class FlaskTestCase(unittest.TestCase):
    def setUp(self):
        self.app = create_app()  # Pass the test_config dictionary
        self.client = self.app.test_client()
        self.app_context = self.app.app_context()
        self.app_context.push()

    def tearDown(self):
        """Teardown test application context."""
        # Tear down database (e.g., drop tables)

        self.app_context.pop()

    def test_register(self):
        """Test the registration endpoint."""
        user_data = {
            'username': 'testuser',
            'password': 'testpass',
            'first_name': 'New',
            'last_name': 'User',
            'gender': 'male',
            'date_of_birth': '2002-12-21',
            "activity_level": "active",
            "goals": ["lose weight", "improve cardio"],
            "fitness_level": "intermediate",
            "height_cm": 120,
            "weight_kg": 100,
            # Add other required fields...
        }
        response = self.client.post('/register', json=user_data)
        self.assertEqual(response.status_code, 201)
        self.assertIn('Registration successful', response.json['message'])
        
    def test_login(self):
        """Test the login endpoint."""
        response = self.client.post('/login', json={
            'username': 'testuser',
            'password': 'testpass'
        })
        self.assertEqual(response.status_code, 200)
        self.assertIn('Login successful', response.json['message'])

    
    
    def test_update_user_profile(self):
        """Test the profile update endpoint."""
        update_data = {
            "username": 'testuser',
            "height_cm": 130,
            "weight_kg": 150,
            "activity_level": "active",
            "goals": ["improve posture"],
            "fitness_level": "intermediate",
            # Add fields to be updated...
            }
        response = self.client.post('/update_profile', json=update_data)
        self.assertEqual(response.status_code, 200)
        self.assertIn('Profile updated successfully', response.json['message'])

    def test_initialize_daily_log(self):
        """Test the initialize daily log endpoint."""
        # Assuming 'testuser' is already registered in your test database
        request_data = {
            'username': 'testuser',
            'date': '2024-02-22'  # Use a specific date for testing
        }
        response = self.client.post('/initialize_daily_log', json=request_data)
        self.assertEqual(response.status_code, 200)
        
    #    self.assertIn('Daily log', response.json['message'])



    def test_log_calorie_intake(self):
        # Example data for the test
        data = {
            "username": "testuser",
            "date_logged": "2024-02-22",
            "meals": [{"meal_type": "breakfast", "calories": 300}]
        }
        response = self.client.post('/log/calorie_intake', json=data)
        self.assertEqual(response.status_code, 201)
        self.assertIn('Calorie intake logged successfully', response.json['message'])

    def test_log_exercise(self):
        # Example data for the test
        data = {
            "username": "testuser",
            "date_logged": "2024-02-22",
            "exercises": [{"type": "running", "duration": 30, "calories_burned": 200}]
        }
        response = self.client.post('/log/exercise', json=data)
        self.assertEqual(response.status_code, 201)
        self.assertIn('Exercise logged successfully', response.json['message'])

    def test_log_body_metrics(self):
        # Example data for the test
        data = {
            "username": "testuser",
            "date_logged": "2024-02-22",
            "metrics": {"weight_kg": 70, "height_cm": 175}
        }
        response = self.client.post('/log/body_metrics', json=data)
        self.assertEqual(response.status_code, 201)
        self.assertIn('Body metrics logged successfully', response.json['message'])

    def test_get_profile(self):
        # Mocking the database cursor's behavior
        # Assuming the username 'john_doe' exists in your database with a weight that corresponds to the 155 lb column
        response = self.client.get('/profile/testuser')
        self.assertEqual(response.status_code, 200)
        # Here you can add more assertions to check if the response data is as expected
        # This is a basic example, you'd likely want to check the structure and content of the response data


    def test_get_exercise_info(self):
        # Mocking the database cursor's behavior
        # Assuming the username 'john_doe' exists in your database with a weight that corresponds to the 155 lb column
        response = self.client.get('/get_exercise_info/newuser')
        self.assertEqual(response.status_code, 200)
        # Here you can add more assertions to check if the response data is as expected
        # This is a basic example, you'd likely want to check the structure and content of the response data

    def test_get_exercise_info(self):
        # Mocking the database cursor's behavior
        # Assuming the username 'john_doe' exists in your database with a weight that corresponds to the 155 lb column
        response = self.client.get('/get_exercise_records/testuser')
        self.assertEqual(response.status_code, 200)
        # Here you can add more assertions to check if the response data is as expected
        # This is a basic example, you'd likely want to check the structure and content of the response data

    def test_add_user_condition(self):
        """Test adding a user condition."""
        response = self.client.post('/add_user_condition', json={
            'username': 'testuser',  # Assuming 'testuser' exists
            'condition_description': 'do not use leg'
        })
        self.assertEqual(response.status_code, 200)
        self.assertIn('User condition added successfully', response.json['message'])


    def test_get_conditions(self):
        """Test retrieving user conditions."""
        response = self.client.get('/get_conditions/testuser')  # Assuming 'testuser' exists
        self.assertEqual(response.status_code, 200)
        self.assertIn('Conditions retrieved successfully', response.json['message'])
        # Here you might want to check if the conditions in the response are as expected.
    def test_user_info(self):
        # Example data for the test
        data = {
            "username": "testuser",
            "date": "2024-02-22",
        }
        response = self.client.post('/get_recommendation', json=data)
        print(response.json)
        self.assertEqual(response.status_code, 201)

        
    def test_calculate_calories(self):
        # Replace 'running', 30, and the expected_calories_burned with appropriate values based on your CSV
        data = {
            "username": "testuser",
            "exercise_name": "Running, 5 mph (12 minute mile)",
            "duration_minutes": 30
        }
        
        # Perform a POST request to the calculate_calories endpoint
        response = self.client.post('/calculate_calories', json=data)
        
        # Assert that the response status code is 200 (success)
        self.assertEqual(response.status_code, 200)
        
        # Check the response for the expected calories burned
        # This value should be based on the 'running' exercise for 30 minutes from your CSV
        # and the weight of 'testuser' in your test database.
        # You will need to manually calculate this expected value based on your CSV and user weight.
        expected_calories_burned = 123.5865 # Calculate based on your CSV and 'testuser' weight
        
        # Assert that the calculated calories are as expected
        self.assertAlmostEqual(response.json['calories_burned'], expected_calories_burned, places=2)

        # Check for success message
        self.assertEqual(response.json['status'], 'success')
        self.assertIn('Calories calculated successfully', response.json['message'])


    def test_calculate_calories(self):
        # Perform a POST request to the calculate_calories endpoint
        response = self.client.get('/list_exercises/testuser')
        
        # Assert that the response status code is 200 (success)
        self.assertEqual(response.status_code, 200)
        
        self.assertEqual(response.json['status'], 'success')
        
if __name__ == '__main__':
    unittest.main()
