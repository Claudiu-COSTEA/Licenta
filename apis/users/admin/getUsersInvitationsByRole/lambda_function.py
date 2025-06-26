# lambda_function.py – GET invitations filtrate după competition_UUID + role
import json, pymysql

# ─── CONFIG ─────────────────────────────────────────────
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASS = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def db():
    return pymysql.connect(
        host=DB_HOST, user=DB_USER, password=DB_PASS,
        database=DB_NAME, autocommit=True,
        cursorclass=pymysql.cursors.DictCursor
    )

# ─── HANDLER ────────────────────────────────────────────
def lambda_handler(event, context):
    """
    Acceptă:
      • body JSON    ⇒ {"role":"Referee","competition_UUID":"2"}
      • query-string ⇒ ?role=Referee&competition_UUID=2
    """

    # 2) extrage parametrii (cu fallback la query-string)
    role = event["recipient_role"] 
    comp = event["competition_UUID"]

    # 3) validare: ambele trebuie să fie string ne-gol
    if not isinstance(role, str) or not isinstance(comp, str):
        return {
            "statusCode": 400,
            "body": json.dumps({
                "error": "role (string) și competition_UUID (string) sunt obligatorii"
            }),
        }

    # 4) interogare BD
    try:
        conn = db()
        with conn.cursor() as cur:
            sql = """
                SELECT *
                  FROM competitions_invitations
                 WHERE recipient_role = %s
                   AND competition_UUID = %s
            """
            cur.execute(sql, (role.strip(), comp.strip()))
            invites = cur.fetchall()
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

    # 5) răspuns
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(invites, default=str)
    }
