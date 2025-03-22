import pymysql

# Database connection details (adjust if using environment variables)
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASSWORD = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def connect_to_db():
    """Establish MySQL database connection."""
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
        body = event["body"]

        # Required fields
        competition_uuid = body.get("competition_UUID")
        recipient_uuid = body.get("recipient_UUID")
        recipient_role = body.get("recipient_role")
        referee_verification = body.get("referee_verification")

        # Validate presence of fields
        if not all([competition_uuid, recipient_uuid, recipient_role, referee_verification]):
            return {
                "statusCode": 400,
                "body": {"error": "Missing required fields"}
            }

        # Validate referee_verification value
        allowed_statuses = ["Confirmed", "Declined"]
        if referee_verification not in allowed_statuses:
            return {
                "statusCode": 400,
                "body": {"error": "Invalid verification status"}
            }

        conn = connect_to_db()
        if conn is None:
            return {
                "statusCode": 500,
                "body": {"error": "Database connection failed"}
            }

        with conn.cursor() as cursor:
            # Check if the invitation exists
            check_query = """
                SELECT 1 FROM competitions_invitations
                WHERE competition_UUID = %s
                  AND recipient_UUID = %s
                  AND recipient_role = %s
            """
            cursor.execute(check_query, (competition_uuid, recipient_uuid, recipient_role))
            if cursor.rowcount == 0:
                return {
                    "statusCode": 404,
                    "body": {"error": "Invitation not found"}
                }

            # Update the referee_verification field
            update_query = """
                UPDATE competitions_invitations
                SET referee_verification = %s
                WHERE competition_UUID = %s
                  AND recipient_UUID = %s
                  AND recipient_role = %s
            """
            cursor.execute(update_query, (
                referee_verification, competition_uuid, recipient_uuid, recipient_role
            ))
            conn.commit()

        return {
            "statusCode": 200,
            "body": {"success": "Referee verification successfully"}
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }
