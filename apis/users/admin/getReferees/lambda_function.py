# lambda_function.py – GET referees (toți sau pe stil)
import json, pymysql

# ─── CONFIG ─────────────────────────────────────────────
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASS = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def db():
    return pymysql.connect(
        host        = DB_HOST,
        user        = DB_USER,
        password    = DB_PASS,
        database    = DB_NAME,
        autocommit  = True,
        cursorclass = pymysql.cursors.DictCursor
    )

# ─── HANDLER ────────────────────────────────────────────
def lambda_handler(event, context):
    """
    Acceptă (opţional):
      • body JSON       ⇒ {"wrestling_style": "Greco Roman"}
      • query-string    ⇒ ?wrestling_style=Greco%20Roman

    Dacă nu trimitem `wrestling_style`, întoarce toţi arbitrii.
    """

    # 1) body poate veni ca dict sau ca string
    body = event.get("body") or {}
    if isinstance(body, str):
        try:
            body = json.loads(body)
        except json.JSONDecodeError:
            body = {}

    # 2) extragem stilul (din body sau query-string)
    style = (
        body.get("wrestling_style")
        or event.get("queryStringParameters", {}).get("wrestling_style")
    )
    style = style.strip() if isinstance(style, str) else None   # sanitizare

    # 3) interogare BD
    try:
        conn = db()
        with conn.cursor() as cur:
            if style:
                sql = """
                    SELECT r.referee_UUID,
                           u.user_full_name,
                           r.wrestling_style
                      FROM referees r
                      JOIN users u ON u.user_UUID = r.referee_UUID
                     WHERE r.wrestling_style = %s
                """
                cur.execute(sql, (style,))
            else:
                sql = """
                    SELECT r.referee_UUID,
                           u.user_full_name,
                           r.wrestling_style
                      FROM referees r
                      JOIN users u ON u.user_UUID = r.referee_UUID
                """
                cur.execute(sql)
            refs = cur.fetchall()
    except Exception as exc:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": f"Eroare BD: {exc}"}),
        }
    finally:
        try:
            conn.close()
        except Exception:
            pass

    # 4) răspuns
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps(refs, default=str),
    }
