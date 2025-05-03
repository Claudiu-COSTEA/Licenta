import json
import pymysql

# Database connection details (hard-coded)
DB_HOST     = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER     = "admin"
DB_PASSWORD = "admin123"
DB_NAME     = "wrestlingMobileAppDatabase"

_connection = None
def get_connection():
    global _connection
    if _connection is None or not _connection.open:
        _connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            connect_timeout=5,
            autocommit=True,
            cursorclass=pymysql.cursors.DictCursor
        )
    return _connection


def lambda_handler(event, context):
    """
    Lambda GET handler pentru competiții.
    Returnează toate competițiile cu datele lor:
      [
        {
          "competition_UUID": 1,
          "competition_name": "Cupa Primăverii",
          "competition_start_date": "2025-05-10T09:00:00",
          "competition_end_date": "2025-05-12T18:00:00",
          "competition_location": "București",
          "competition_status": "Pending"
        },
        ...
      ]
    """
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute(
                "SELECT competition_UUID, competition_name, competition_start_date, competition_end_date, competition_location, competition_status FROM competitions;"
            )
            rows = cur.fetchall()
    except Exception as err:
        print("DB error:", err)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal server error"})
        }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(rows, default=str, ensure_ascii=False)
    }

