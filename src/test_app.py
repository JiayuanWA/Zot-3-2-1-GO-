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

    def test_login(self):
        """Test the login endpoint."""
        response = self.client.post('/login', json={
            'username': 'testuser',
            'password': 'testpass'
        })
        self.assertEqual(response.status_code, 200)
        self.assertIn('Login successful', response.json['message'])

    def test_register(self):
        """Test the registration endpoint."""
        user_data = {
            'username': 'newuser',
            'password': 'newpass',
            'first_name': 'New',
            'last_name': 'User',
            "activity_level": "active",
            "goals": ["lose weight", "improve cardio"],
            "fitness_level": "intermediate",
            "workout_days": ["Monday", "Wednesday", "Friday"]
            # Add other required fields...
        }
        response = self.client.post('/register', json=user_data)
        self.assertEqual(response.status_code, 201)
        self.assertIn('Registration successful', response.json['message'])

    def test_update_user_profile(self):
        """Test the profile update endpoint."""
        update_data = {
            'username': 'existinguser',
            # Add fields to be updated...
        }
        response = self.client.post('/profile/update', json=update_data)
        self.assertEqual(response.status_code, 200)
        self.assertIn('Profile updated successfully', response.json['message'])

if __name__ == '__main__':
    unittest.main()
