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

def serialize_datetime(obj):
    """Convert datetime objects to string format (ISO 8601)."""
    if isinstance(obj, datetime):
        return obj.strftime("%Y-%m-%d %H:%M:%S")  # Converts datetime to string format
    return obj

def lambda_handler(event, context):
    """AWS Lambda function to fetch competition invitations based on recipient_UUID."""

    # ✅ Extract recipient_UUID from query parameters
    recipient_uuid = event["recipient_UUID"]

    if not recipient_uuid:
        return {
            "statusCode": 400,
            "body": {"error": "recipient_UUID is required"}
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
            sql_query = """
                SELECT 
                    ci.competition_invitation_UUID AS invitationUUID,
                    ci.competition_UUID,
                    ci.recipient_UUID,
                    ci.recipient_role,
                    ci.weight_category,
                    c.competition_name,
                    c.competition_start_date,
                    c.competition_end_date,
                    c.competition_location,
                    ci.invitation_status,
                    ci.invitation_date,
                    ci.invitation_deadline,
                    ci.invitation_response_date
                FROM competitions_invitations ci
                JOIN competitions c ON ci.competition_UUID = c.competition_UUID
                WHERE ci.recipient_UUID = %s
            """
            cursor.execute(sql_query, (recipient_uuid,))
            invitations = cursor.fetchall()

        if invitations:
            # ✅ Convert datetime objects to string before returning
            invitations_serialized = [{k: serialize_datetime(v) for k, v in inv.items()} for inv in invitations]

            return {
                "statusCode": 200,
                "body": invitations_serialized
            }
        else:
            return {
                "statusCode": 404,
                "body": {"message": "No invitations found"}
            }
    
    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }
    
    finally:
        connection.close()
