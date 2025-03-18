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
    """Lambda function to send a competition invitation."""
    try:
        # Parse the body, which is a string coming from API Gateway
        body = event["body"]

        # Retrieve data from the body
        competition_UUID = body.get('competition_UUID')
        recipient_UUID = body.get('recipient_UUID')
        recipient_role = body.get('recipient_role')
        weight_category = body.get('weight_category', None)  # Optional
        invitation_status = body.get('invitation_status')
        invitation_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')  # Always set to current date and time
        invitation_deadline = body.get('invitation_deadline')
        invitation_response_date = body.get('invitation_response_date', None)  # Optional
        referee_verification = body.get('referee_verification', None)  # Optional

        # Check for required fields (just an example of validation)
        if not competition_UUID or not recipient_UUID or not recipient_role or not invitation_status or not invitation_deadline:
            return {
                "statusCode": 400,
                "body": {"error": "'competition_UUID', 'recipient_UUID', 'recipient_role', 'invitation_status', and 'invitation_deadline' are required"}
            }

        # Convert invitation_date and invitation_deadline to datetime objects
        invitation_deadline = datetime.strptime(invitation_deadline, '%Y-%m-%d %H:%M:%S')

        # Connect to the database
        connection = connect_to_db()
        if not connection:
            return {
                "statusCode": 500,
                "body": {"error": "Database connection failed"}
            }

        with connection.cursor() as cursor:
            # Prepare the SQL query to insert the invitation
            sql_query = """
                INSERT INTO competitions_invitations (
                    competition_UUID, 
                    recipient_UUID, 
                    recipient_role, 
                    weight_category, 
                    invitation_status, 
                    invitation_date, 
                    invitation_deadline, 
                    invitation_response_date, 
                    referee_verification
                ) 
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql_query, (
                competition_UUID,
                recipient_UUID,
                recipient_role,
                weight_category,
                invitation_status,
                invitation_date,  # Always set to current date and time
                invitation_deadline,
                invitation_response_date,
                referee_verification
            ))
            connection.commit()

        # Return success response
        return {
            "statusCode": 201,
            "body": {"message": "Competition invitation sent successfully!"}
        }

    except Exception as e:
        # In case of an error, return a 400 status code
        return {
            "statusCode": 400,
            "body": {"error": str(e)}
        }
