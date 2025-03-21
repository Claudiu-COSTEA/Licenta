import json
import pymysql

# Database connection details (use environment variables in production)
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
    # Extract parameters from the event
    wrestling_club_uuid = event["wrestling_club_UUID"]
    competition_uuid = event["competition_UUID"]

    if not wrestling_club_uuid or not competition_uuid:
        return {
            "statusCode": 400,
            "body": json.dumps("Missing parameters.")
        }

    conn = connect_to_db()
    if conn is None:
        return {
            "statusCode": 500,
            "body": json.dumps("Database connection failed.")
        }

    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    c.coach_UUID,
                    u.user_full_name AS coach_name,
                    c.wrestling_style,
                    ci.invitation_status
                FROM coaches c
                JOIN users u ON c.coach_UUID = u.user_UUID
                LEFT JOIN competitions_invitations ci 
                    ON c.coach_UUID = ci.recipient_UUID 
                    AND ci.competition_UUID = %s
                    AND ci.recipient_role = 'Coach'
                WHERE c.wrestling_club_UUID = %s
            """
            cursor.execute(sql, (competition_uuid, wrestling_club_uuid))
            results = cursor.fetchall()

        return {
            "statusCode": 200,
            "body": json.dumps(results)
        }

    except Exception as e:
        print("Query failed:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps(f"Query failed: {str(e)}")
        }

    finally:
        conn.close()
