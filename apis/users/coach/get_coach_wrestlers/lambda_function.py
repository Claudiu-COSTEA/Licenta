import pymysql

# Database configuration
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASSWORD = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def connect_to_db():
    """Establish a connection to the MySQL RDS database."""
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

    coach_uuid = event["coach_UUID"]
    competition_uuid = event["competition_UUID"]

    # Validate input
    if not coach_uuid or not competition_uuid:
        return {
            "statusCode": 400,
            "body": {"error": "coach_UUID and competition_UUID are required"}
        }

    conn = connect_to_db()
    if not conn:
        return {
            "statusCode": 500,
            "body": {"error": "Database connection failed"}
        }

    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    w.wrestler_UUID,
                    u.user_full_name AS wrestler_name,
                    w.wrestling_style,
                    ci.weight_category,
                    ci.invitation_status
                FROM wrestlers w
                JOIN users u ON w.wrestler_UUID = u.user_UUID
                LEFT JOIN competitions_invitations ci 
                    ON w.wrestler_UUID = ci.recipient_UUID 
                    AND ci.competition_UUID = %s
                    AND ci.recipient_role = 'Wrestler'
                WHERE w.coach_UUID = %s
            """
            cursor.execute(sql, (competition_uuid, coach_uuid))
            wrestlers = cursor.fetchall()

        return {
            "statusCode": 200,
            "body": wrestlers if wrestlers else {
                "message": "No wrestlers found for this coach in the given competition"
            }
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }

    finally:
        conn.close()
