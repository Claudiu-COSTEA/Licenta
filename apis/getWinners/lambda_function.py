import pymysql

# ─── RDS credentials (hard-coded) ─────────────────────────────
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASS = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

# ─── single reusable connection ──────────────────────────────
_conn = None
def db():
    global _conn
    if _conn and _conn.open:
        return _conn
    _conn = pymysql.connect(
        host        = DB_HOST,
        user        = DB_USER,
        password    = DB_PASS,
        database    = DB_NAME,
        autocommit  = True,
        cursorclass = pymysql.cursors.DictCursor
    )
    return _conn

# ─── query: winners for comp/style/category ──────────────────
SQL = """
SELECT DISTINCT
       cf.wrestler_UUID_winner                           AS wrestler_UUID,
       u.user_full_name,
       cf.competition_fight_weight_category              AS weight_category,
       cf.wrestling_style,
       c.coach_UUID,
       c.wrestling_club_UUID
FROM competitions_fights cf
JOIN users      u ON u.user_UUID       = cf.wrestler_UUID_winner
JOIN wrestlers  w ON w.wrestler_UUID   = cf.wrestler_UUID_winner
JOIN coaches    c ON c.coach_UUID      = w.coach_UUID
WHERE cf.competition_UUID                = %s
  AND cf.wrestling_style                 = %s
  AND cf.competition_fight_weight_category = %s
  AND cf.wrestler_UUID_winner IS NOT NULL;
"""

# ─── Lambda handler ──────────────────────────────────────────
def lambda_handler(event, context):
    comp = event["competition_uuid"]
    sty  = event["wrestling_style"]
    kg   = event["weight_category"]

    if not (comp and sty and kg):
        return {
            "statusCode": 400,
            "body": {
                "error": "competition_uuid, wrestling_style, weight_category required"
            }
        }

    try:
        with db().cursor() as cur:
            cur.execute(SQL, (int(comp), sty, kg))
            rows = cur.fetchall()
    except Exception as exc:
        return {"statusCode": 500, "body": {"error": str(exc)}}

    return {"statusCode": 200, "body": rows}
