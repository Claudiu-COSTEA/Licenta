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
    """AWS Lambda function to fetch user data using GET method (query parameter)."""

    # ✅ Extract email from query parameters
    email = event["email"]

    if not email:
        return {
            "statusCode": 400,
            "body": {"error": "Email parameter is required"}
        }

    # ✅ Connect to the database
    connection = connect_to_db()
    if not connection:
        return {
            "statusCode": 500,
            "body": {"error": "Database connection failed"}
        }

    try:
        with connection.cursor() as cursor:
            sql_query = "SELECT * FROM users WHERE user_email = %s;"
            cursor.execute(sql_query, (email,))
            user = cursor.fetchone()  # Fetch one user
            
        if user:
            return {
                "statusCode": 200,
                "body": user
            }
        else:
            return {
                "statusCode": 404,
                "body": {"error": "User not found"}
            }
    
    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }
    
    finally:
        connection.close()
