import pymysql
from datetime import datetime

# Database config
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASSWORD = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def connect_to_db():
    """Establish database connection."""
    try:
        return pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
    except Exception as e:
        print(f"Connection error: {str(e)}")
        return None

def lambda_handler(event, context):
    try:
        # Parse JSON body
        body = event["body"]

        competition_uuid = body.get("competition_UUID")
        recipient_uuid = body.get("recipient_UUID")
        invitation_deadline = body.get("invitation_deadline")
        weight_category = body.get("weight_category")

        # Validate required fields
        if not all([competition_uuid, recipient_uuid, invitation_deadline, weight_category]):
            return {
                "statusCode": 400,
                "body": {"error": "Missing required fields"}
            }

        # Set defaults
        invitation_status = "Pending"
        recipient_role = "Wrestler"
        invitation_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        conn = connect_to_db()
        if conn is None:
            return {
                "statusCode": 500,
                "body": {"error": "Database connection failed"}
            }

        with conn.cursor() as cursor:
            insert_query = """
                INSERT INTO competitions_invitations (
                    competition_UUID, recipient_UUID, recipient_role, 
                    invitation_status, invitation_date, invitation_deadline, weight_category
                ) VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(insert_query, (
                competition_uuid,
                recipient_uuid,
                recipient_role,
                invitation_status,
                invitation_date,
                invitation_deadline,
                weight_category
            ))
            conn.commit()

        return {
            "statusCode": 200,
            "body": {"success": "Invitation sent successfully to wrestler"}
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }
