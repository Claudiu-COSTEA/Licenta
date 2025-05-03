import json
import pymysql

# — RDS connection settings (hard-coded) —
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
    GET handler that returns for each wrestling-club invitation:
      - club_name
      - city
      - invitation_status
      - invitation_deadline (formatted as YYYY-MM-DD HH:MM:SS)
    """
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                  u.user_full_name            AS club_name,
                  wc.wrestling_club_city      AS city,
                  ci.invitation_status        AS invitation_status,
                  DATE_FORMAT(
                    ci.invitation_deadline,
                    '%Y-%m-%d %H:%i:%s'
                  )                           AS invitation_deadline
                FROM competitions_invitations ci
                JOIN wrestling_club wc
                  ON wc.wrestling_club_UUID = ci.recipient_UUID
                JOIN users u
                  ON u.user_UUID = wc.wrestling_club_UUID
                WHERE ci.recipient_role = 'Wrestling Club';
            """)
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
            "Content-Type":                "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(rows, ensure_ascii=False)
    }
