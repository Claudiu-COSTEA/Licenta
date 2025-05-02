import pymysql

# ─── DB conf ───────────────────────────────────────────────────
DB_HOST     = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER     = "admin"
DB_PASSWORD = "admin123"
DB_NAME     = "wrestlingMobileAppDatabase"

# ─── singleton connection ──────────────────────────────────────
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
    Endpoint accepts ONLY:
      • competition_UUID   (int, required)
      • wrestling_style    (str, required)

    Examples
    --------
    GET  /refs?competition_UUID=1&wrestling_style=Greco%20Roman
    POST body form-urlencoded:
         competition_UUID=1&wrestling_style=Greco Roman
    """

    # 1️⃣  Extract params (query-string first, then top-level keys)
    qs   = event.get("queryStringParameters") or {}
    comp = qs.get("competition_UUID")  or event.get("competition_UUID")
    sty  = qs.get("wrestling_style")   or event.get("wrestling_style")

    # 2️⃣  Validate (both required)
    try:
        comp = int(comp)
        sty  = sty.strip()
        if not sty:
            raise ValueError
    except (TypeError, ValueError, AttributeError):
        return {
            "statusCode": 400,
            "body": {
                "error": "competition_UUID (int) and wrestling_style are BOTH required"
            }
        }

    sql = """
        SELECT r.referee_UUID
        FROM competitions_invitations ci
        JOIN referees r ON r.referee_UUID = ci.recipient_UUID
        WHERE ci.competition_UUID   = %s
          AND ci.invitation_status  = 'Confirmed'
          AND ci.recipient_role     = 'Referee'
          AND r.wrestling_style     = %s;
    """

    try:
        with db().cursor() as cur:
            cur.execute(sql, (comp, sty))
            refs = cur.fetchall()          # list[dict]  e.g. [{'referee_UUID': 28}, …]
    except Exception as exc:
        return {"statusCode": 500, "body": {"error": str(exc)}}

    if refs:
        return {"statusCode": 200, "body": refs}
    return {"statusCode": 404, "body": {"message": "No referees found for given filters"}}
