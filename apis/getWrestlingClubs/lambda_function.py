import json
import decimal
import pymysql

# ---------- conexiune RDS ---------
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASSWORD = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

_conn = None
def conn():
    global _conn
    if _conn is None or not _conn.open:
        _conn = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            autocommit=True,
            cursorclass=pymysql.cursors.DictCursor
        )
    return _conn


def lambda_handler(event, context):
    """
    Răspuns    200 OK
    [
      {
        "wrestling_club_UUID": 28,
        "club_name": "CSA Steaua",          # din tabela users
        "city": "București",
        "latitude": 44.4268,
        "longitude": 26.1025
      },
      ...
    ]
    """
    try:
        with conn().cursor() as cur:
            cur.execute(
                """
                SELECT
                  wc.wrestling_club_UUID,
                  u.user_full_name      AS club_name,
                  wc.wrestling_club_city        AS city,
                  wc.wrestling_club_latitude    AS latitude,
                  wc.wrestling_club_longitude   AS longitude
                FROM wrestling_club wc
                JOIN users u ON u.user_UUID = wc.wrestling_club_UUID
                ORDER BY u.user_full_name;
                """
            )
            rows = cur.fetchall()

            # pymysql întoarce DECIMAL pentru lat/lon → convertim la float
            for r in rows:
                r["latitude"]  = float(r["latitude"])
                r["longitude"] = float(r["longitude"])

    except Exception as exc:
        print("DB error:", exc)
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
        "body": json.dumps(rows, ensure_ascii=False)
    }
