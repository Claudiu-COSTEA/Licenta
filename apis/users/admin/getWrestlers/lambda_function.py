# lambda_function.py – GET: toți luptătorii
import json, pymysql

# ─── CONFIG ──────────────────────────────────────────────
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASS = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def db_conn():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        autocommit=True,
        cursorclass=pymysql.cursors.DictCursor
    )

# ─── HANDLER ─────────────────────────────────────────────
def lambda_handler(event, context):
    """
    Nu primeşte niciun parametru.
    Returnează toţi luptătorii (wrestlers) cu:
      • wrestler_UUID
      • wrestler_name     (din tabela users)
      • wrestling_style
      • coach_UUID
      • date_of_registration
      • medical_document
      • license_document
    """

    try:
        conn = db_conn()
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    w.wrestler_UUID,
                    u.user_full_name          AS wrestler_name,
                    w.wrestling_style,
                    w.coach_UUID,
                    w.date_of_registration,
                    w.medical_document,
                    w.license_document
                FROM wrestlers w
                JOIN users     u ON u.user_UUID = w.wrestler_UUID
            """)
            wrestlers = cur.fetchall()

    except Exception as exc:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": f"DB error: {exc}"})
        }
    finally:
        try: conn.close()
        except Exception: pass

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(wrestlers, default=str)  # default=str pentru date/datetime
    }
