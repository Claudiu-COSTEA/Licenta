import pymysql

# Database connection configuration
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASSWORD = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def connect_to_db():
    """Connect to the RDS MySQL database."""
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

    wrestling_style = event["wrestling_style"]
    weight_category = event["weight_category"]
    competition_UUID = event["competition_UUID"]

    # Validate required parameters
    if not wrestling_style or not weight_category or not competition_UUID:
        return {
            "statusCode": 400,
            "body": { "error": "wrestling_style, weight_category, and competition_UUID are required"}
        }

    conn = connect_to_db()
    if conn is None:
        return {
            "statusCode": 500,
            "body": {"error": "Database connection failed"}
        }

    try:
        with conn.cursor() as cursor:
            query = """
                SELECT 
                    w.wrestler_UUID,
                    wu.user_full_name AS wrestler_name,
                    w.wrestling_style,
                    ci.weight_category,
                    c.coach_UUID,
                    cu.user_full_name AS coach_name,
                    wc.wrestling_club_UUID,
                    wu_club.user_full_name AS wrestling_club_name,
                    comp.competition_UUID,
                    comp.competition_name,
                    ci.invitation_status,
                    ci.referee_verification
                FROM wrestlers w
                JOIN users wu ON w.wrestler_UUID = wu.user_UUID
                JOIN coaches c ON w.coach_UUID = c.coach_UUID
                JOIN users cu ON c.coach_UUID = cu.user_UUID
                JOIN wrestling_club wc ON c.wrestling_club_UUID = wc.wrestling_club_UUID
                JOIN users wu_club ON wc.wrestling_club_UUID = wu_club.user_UUID
                JOIN competitions_invitations ci ON w.wrestler_UUID = ci.recipient_UUID 
                    AND ci.recipient_role = 'Wrestler'
                    AND ci.competition_UUID = %s
                    AND ci.invitation_status = 'Accepted'
                JOIN competitions comp ON ci.competition_UUID = comp.competition_UUID
                WHERE w.wrestling_style = %s
                  AND ci.weight_category = %s
            """
            cursor.execute(query, (competition_UUID, wrestling_style, weight_category))
            wrestlers = cursor.fetchall()

        return {
            "statusCode": 200,
            "body": wrestlers if wrestlers else {
                "message": "No wrestlers found for the given criteria"
            }
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }

    finally:
        conn.close()
