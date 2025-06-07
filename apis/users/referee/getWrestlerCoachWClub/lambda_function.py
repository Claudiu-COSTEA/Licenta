import json
import pymysql

# RDS MySQL connection settings
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
        print(f"DB connection error: {e}")
        return None

def lambda_handler(event, context):
    """
    Lambda to fetch wrestler details:
    - Wrestler full name
    - Coach full name
    - Club full name
    Expects event["wrestler_UUID"] (int).
    """
    wid = event.get("wrestler_UUID")
    if wid is None:
        return {
            "statusCode": 400,
            "body": {"error": "wrestler_UUID parameter is required"}
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
              u_w.user_full_name    AS wrestler_name,
              u_c.user_full_name    AS coach_name,
              u_cl.user_full_name   AS club_name
            FROM wrestlers w
            JOIN users u_w  ON w.wrestler_UUID      = u_w.user_UUID
            JOIN coaches c ON w.coach_UUID          = c.coach_UUID
            JOIN users u_c  ON c.coach_UUID          = u_c.user_UUID
            JOIN wrestling_club wc ON c.wrestling_club_UUID = wc.wrestling_club_UUID
            JOIN users u_cl ON wc.wrestling_club_UUID = u_cl.user_UUID
            WHERE w.wrestler_UUID = %s;
            """
            cursor.execute(sql, (wid,))
            row = cursor.fetchone()

        if not row:
            return {
                "statusCode": 404,
                "body": {"error": "Wrestler not found"}
            }

        return {
            "statusCode": 200,
            "body": row
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }
    finally:
        conn.close()
