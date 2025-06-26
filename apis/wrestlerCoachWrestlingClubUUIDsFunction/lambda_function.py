import pymysql
import os

# ─── DB conf (move to env vars in prod) ─────────────────────────
DB_HOST     = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER     = "admin"
DB_PASSWORD = "admin123"
DB_NAME     = "wrestlingMobileAppDatabase"

# ─── single reusable connection ─────────────────────────────────
_conn = None
def db():
    global _conn
    if _conn and _conn.open:
        return _conn
    _conn = pymysql.connect(
        host=DB_HOST, user=DB_USER, password=DB_PASSWORD, database=DB_NAME,
        autocommit=True, cursorclass=pymysql.cursors.DictCursor
    )
    return _conn


# ─── Lambda handler ────────────────────────────────────────────
def lambda_handler(event, context):
    """
    Works with:
      GET  /path?competition_uuid=1&wrestling_style=Greco%20Roman&weight_category=77
      POST body: competition_uuid=1&wrestling_style=Greco%20Roman&weight_category=77
    """

    # -------- 1. pull parameters (query-string first) ----------
    qs   = event.get("queryStringParameters") or {}
    comp = qs.get("competition_uuid")  or event.get("competition_uuid")
    sty  = qs.get("wrestling_style")   or event.get("wrestling_style")
    kg   = qs.get("weight_category")   or event.get("weight_category")

    try:
        comp = int(comp)
        sty  = sty.strip()
        kg   = kg.strip()
        if not sty or not kg:
            raise ValueError
    except (TypeError, ValueError, AttributeError):
        return {
            "statusCode": 400,
            "body": {
                "error": "competition_uuid (int), wrestling_style and weight_category are required"
            }
        }

    sql = """
        SELECT DISTINCT
               w.wrestler_UUID,
               w.coach_UUID,
               c.wrestling_club_UUID
        FROM competitions_invitations ci
        JOIN wrestlers w ON w.wrestler_UUID = ci.recipient_UUID
        JOIN coaches   c ON c.coach_UUID    = w.coach_UUID
        WHERE ci.recipient_role           = 'Wrestler'
          AND ci.referee_verification     = 'Confirmed'
          AND ci.invitation_response_date IS NOT NULL
          AND ci.competition_UUID         = %s
          AND ci.weight_category          = %s
          AND w.wrestling_style           = %s;
    """

    try:
        with db().cursor() as cur:
            cur.execute(sql, (comp, kg, sty))
            rows = cur.fetchall()
    except Exception as exc:
        return {"statusCode": 500, "body": {"error": str(exc)}}

    if rows:
        return {"statusCode": 200, "body": rows}
    return {"statusCode": 404, "body": {"message": "No data for given filters"}}
