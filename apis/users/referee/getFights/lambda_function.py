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
        return pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return None

def lambda_handler(event, context):
    """
    AWS Lambda function to fetch all fights for a given competition_UUID and wrestling_style
    where no winner has yet been recorded (wrestler_UUID_winner IS NULL).
    Expects:
      event["competition_UUID"]    -> int
      event["wrestling_style"]     -> str
    """
    comp_id = event.get("competition_UUID")
    style   = event.get("wrestling_style")

    if comp_id is None or style is None:
        return {
            "statusCode": 400,
            "body": {"error": "Both competition_UUID and wrestling_style are required"}
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
                  competition_fight_UUID,
                  competition_UUID,
                  competition_round,
                  competition_fight_order_number,
                  wrestling_style,
                  competition_fight_weight_category,
                  referee_UUID_1,
                  referee_UUID_2,
                  referee_UUID_3,
                  wrestling_club_UUID_red,
                  wrestling_club_UUID_blue,
                  coach_UUID_red,
                  coach_UUID_blue,
                  wrestler_UUID_red,
                  wrestler_UUID_blue,
                  wrestler_points_red,
                  wrestler_points_blue
                FROM competitions_fights
                WHERE competition_UUID = %s
                  AND wrestling_style = %s
                  AND wrestler_UUID_winner IS NULL
                ORDER BY competition_fight_order_number;
            """
            cursor.execute(sql, (comp_id, style))
            fights = cursor.fetchall()

        return {
            "statusCode": 200,
            "body": fights  # list of dicts
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }
    finally:
        conn.close()
