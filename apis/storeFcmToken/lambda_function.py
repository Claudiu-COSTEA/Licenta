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
    """Lambda function to store the FCM token for a user based on user UUID."""
    try:
        # Parse request body
        body = event["body"]  # Parse JSON from the request

        # Extract required fields
        user_uuid = body.get("user_UUID")
        fcm_token = body.get("fcm_token")

        # Check if all required fields are provided
        if not user_uuid or not fcm_token:
            return {
                "statusCode": 400,
                "body": {"error": "user_UUID and fcm_token are required"}
            }

        # Connect to the database
        connection = connect_to_db()
        if not connection:
            return {
                "statusCode": 500,
                "body": {"error": "Database connection failed"}
            }

        with connection.cursor() as cursor:
            # SQL Query to insert or update the FCM token for the given user UUID
            sql_query = """
                INSERT INTO users (user_UUID, fcm_token)
                VALUES (%s, %s)
                ON DUPLICATE KEY UPDATE fcm_token = VALUES(fcm_token)
            """
            cursor.execute(sql_query, (user_uuid, fcm_token))
            connection.commit()

            return {
                "statusCode": 200,
                "body": {"message": "FCM token stored successfully"}
            }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }
