import pymysql
from datetime import datetime

# Database config
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASSWORD = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def connect_to_db():
    try:
        return pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
    except Exception as e:
        print(f"DB connection failed: {str(e)}")
        return None

def lambda_handler(event, context):
    try:
        # Parse JSON input
        body = event["body"]

        competition_uuid = body.get("competition_UUID")
        recipient_uuid = body.get("recipient_UUID")
        new_status = body.get("invitation_status")
        new_weight_category = body.get("weight_category")

        # Validate required fields
        if not all([competition_uuid, recipient_uuid, new_status, new_weight_category]):
            return {
                "statusCode": 400,
                "body": {"error": "Missing required fields"}
            }

        invitation_response_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        conn = connect_to_db()
        if conn is None:
            return {
                "statusCode": 500,
                "body": {"error": "Database connection failed"}
            }

        with conn.cursor() as cursor:
            # Check if invitation exists and is 'Pending'
            check_query = """
                SELECT invitation_status
                FROM competitions_invitations
                WHERE competition_UUID = %s
                  AND recipient_UUID = %s
                  AND recipient_role = 'Wrestler'
            """
            cursor.execute(check_query, (competition_uuid, recipient_uuid))
            row = cursor.fetchone()

            if not row:
                return {
                    "statusCode": 404,
                    "body": {"error": "Invitation not found"}
                }

            if row["invitation_status"] != "Pending":
                return {
                    "statusCode": 400,
                    "body": {"error": "Invitation status is not 'Pending' and cannot be updated"}
                }

            # Update invitation
            update_query = """
                UPDATE competitions_invitations
                SET invitation_status = %s,
                    weight_category = %s,
                    invitation_response_date = %s
                WHERE competition_UUID = %s
                  AND recipient_UUID = %s
                  AND recipient_role = 'Wrestler'
            """
            cursor.execute(update_query, (
                new_status, new_weight_category, invitation_response_date,
                competition_uuid, recipient_uuid
            ))
            conn.commit()

        return {
            "statusCode": 200,
            "body": {"success": "Invitation updated successfully"}
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }
