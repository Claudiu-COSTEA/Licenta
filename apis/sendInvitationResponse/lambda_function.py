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
    """Lambda function to update invitation status."""
    try:
        # Parse request body
        body = event["body"] # Parse JSON from the request

        # Extract required fields
        competition_UUID = body.get("competition_UUID")
        recipient_UUID = body.get("recipient_UUID")
        recipient_role = body.get("recipient_role")
        invitation_status = body.get("invitation_status")

        # Check if all required fields are provided
        if not all([competition_UUID, recipient_UUID, recipient_role, invitation_status]):
            return {
                "statusCode": 400,
                "body": {"error": "Missing required fields"}
            }

        # Connect to database
        connection = connect_to_db()
        if not connection:
            return {
                "statusCode": 500,
                "body": {"error": "Database connection failed"}
            }

        with connection.cursor() as cursor:
            # SQL Query to update the invitation status
            sql_query = """
                UPDATE competitions_invitations
                SET invitation_status = %s
                WHERE competition_UUID = %s AND recipient_UUID = %s AND recipient_role = %s
            """
            cursor.execute(sql_query, (invitation_status, competition_UUID, recipient_UUID, recipient_role))
            connection.commit()

            # Check if any rows were updated
            if cursor.rowcount > 0:
                return {
                    "statusCode": 200,
                    "body": {"message": "Invitation status updated successfully"}
                }
            else:
                return {
                    "statusCode": 404,
                    "body": {"error": "No matching invitation found"}
                }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }
