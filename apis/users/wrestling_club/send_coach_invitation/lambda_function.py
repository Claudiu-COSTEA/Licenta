import json
import pymysql
from datetime import datetime

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
    """Lambda function to send a coach invitation."""
    try:
        # Parse the body, which is a string coming from API Gateway
        body = event["body"]

        # Retrieve required fields
        competition_UUID = body.get('competition_UUID')
        recipient_UUID = body.get('recipient_UUID')
        invitation_deadline = body.get('invitation_deadline')

        # Default values
        invitation_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')  # Current timestamp
        invitation_status = "Pending"
        recipient_role = "Coach"

        # Validate required fields
        if not competition_UUID or not recipient_UUID or not invitation_deadline:
            return {
                "statusCode": 400,
                "body": {"error": "'competition_UUID', 'recipient_UUID', and 'invitation_deadline' are required"}
            }

        # Ensure the invitation_deadline follows the format yyyy-MM-dd HH:mm:ss
        try:
            invitation_deadline = datetime.strptime(invitation_deadline, '%Y-%m-%d %H:%M:%S')
        except ValueError:
            return {
                "statusCode": 400,
                "body": {"error": "Invalid date format. Use 'YYYY-MM-DD HH:mm:ss'."}
            }

        # Connect to the database
        connection = connect_to_db()
        if not connection:
            return {
                "statusCode": 500,
                "body": {"error": "Database connection failed"}
            }

        with connection.cursor() as cursor:
            # SQL Query to insert the coach invitation
            sql_query = """
                INSERT INTO competitions_invitations (
                    competition_UUID, 
                    recipient_UUID, 
                    recipient_role, 
                    invitation_status, 
                    invitation_date, 
                    invitation_deadline
                ) 
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql_query, (
                competition_UUID,
                recipient_UUID,
                recipient_role,
                invitation_status,
                invitation_date,  # Automatically set to current time
                invitation_deadline.strftime('%Y-%m-%d %H:%M:%S')
            ))
            connection.commit()

        # Return success response
        return {
            "statusCode": 201,
            "body": {"message": "Coach invitation sent successfully!"}
        }

    except Exception as e:
        # In case of an error, return a 400 status code
        return {
            "statusCode": 400,
            "body": {"error": str(e)}
        }
