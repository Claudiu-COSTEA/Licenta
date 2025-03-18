import json
import pymysql

# Database connection details
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASSWORD = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def connect_to_db():
    """Establish connection to the RDS MySQL database."""
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
        return connection
    except Exception as e:
        print(f"Error connecting to database: {str(e)}")
        return None

def lambda_handler(event, context):
    """Lambda function to get the FCM token for a user based on user UUID."""
    try:
        # Extract user UUID from query parameters
        user_uuid = event["user_UUID"]

        if not user_uuid:
            return {
                "statusCode": 400,
                "body": {"error": "user_UUID is required"}
            }

        # Connect to the database
        connection = connect_to_db()
        if not connection:
            return {
                "statusCode": 500,
                "body": {"error": "Database connection failed"}
            }

        with connection.cursor() as cursor:
            # Prepare SQL query to fetch fcm_token for the given user UUID
            sql_query = "SELECT fcm_token FROM users WHERE user_UUID = %s"
            cursor.execute(sql_query, (user_uuid,))
            result = cursor.fetchone()

            if result:
                # Return the FCM token if user found
                return {
                    "statusCode": 200,
                    "body": {"fcm_token": result["fcm_token"]}
                }
            else:
                # Return an error if user not found
                return {
                    "statusCode": 404,
                    "body": {"error": "User not found"}
                }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }
