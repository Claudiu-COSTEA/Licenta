import json
import pymysql

# RDS settings
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
        print(f"DB connect error: {e}")
        return None

def lambda_handler(event, context):
    """
    GET all competitions from the `competitions` table.
    """
    conn = connect_to_db()
    if not conn:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Database connection failed"})
        }

    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT
                  competition_UUID,
                  competition_name,
                  competition_start_date,
                  competition_end_date,
                  competition_location,
                  competition_status,
                  competition_results
                FROM competitions
                ORDER BY competition_start_date;
            """)
            competitions = cursor.fetchall()

        return {
            "statusCode": 200,
            "body": json.dumps(competitions, default=str)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
    finally:
        conn.close()
