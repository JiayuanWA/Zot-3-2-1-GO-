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

    #def test_login(self):
    #    """Test the login endpoint."""
    #    response = self.client.post('/login', json={
    #        'username': 'testuser',
    #        'password': 'testpass'
    #    })
    #    self.assertEqual(response.status_code, 200)
    #    self.assertIn('Login successful', response.json['message'])

    #def test_register(self):
    #    """Test the registration endpoint."""
    #    user_data = {
    #        'username': 'newuser',
    #        'password': 'newpass',
    #        'first_name': 'New',
    #        'last_name': 'User',
    #        'gender': 'male',
    #        'date_of_birth': '2002-12-21',
    #        "activity_level": "active",
    #        "goals": ["lose weight", "improve cardio"],
    #        "fitness_level": "intermediate",
    #        "height_cm": 120,
    #        "weight_kg": 100,
    #        # Add other required fields...
    #    }
    #    response = self.client.post('/register', json=user_data)
    #    self.assertEqual(response.status_code, 201)
    #    self.assertIn('Registration successful', response.json['message'])

    #def test_update_user_profile(self):
    #    """Test the profile update endpoint."""
    #    update_data = {
    #        "username": 'newuser',
    #        "height_cm": 130,
    #        "weight_kg": 150,
    #        "activity_level": "active",
    #        "goals": ["lose weight", "improve cardio"],
    #        "fitness_level": "intermediate",
    #        # Add fields to be updated...
    #    }
    #    response = self.client.post('/profile/update', json=update_data)
    #    self.assertEqual(response.status_code, 200)
    #    self.assertIn('Profile updated successfully', response.json['message'])

    #def test_initialize_daily_log(self):
    #    """Test the initialize daily log endpoint."""
    #    # Assuming 'testuser' is already registered in your test database
    #    request_data = {
    #        'username': 'newuser',
    #        'date': '2024-02-22'  # Use a specific date for testing
    #    }
    #    response = self.client.post('/initialize_daily_log', json=request_data)
    #    self.assertEqual(response.status_code, 200)
        
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
if __name__ == '__main__':
    unittest.main()
