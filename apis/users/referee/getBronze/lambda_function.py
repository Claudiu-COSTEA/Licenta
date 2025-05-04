import json
import pymysql
import urllib.parse
import urllib3

# ─── GLOBAL HTTP POOL FOR CONNECTION REUSE ─────────────────────
http = urllib3.PoolManager()

# ─── RDS CONNECTION ─────────────────────────────────────
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASS = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def db():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        autocommit=True,
        cursorclass=pymysql.cursors.DictCursor
    )

# ─── FETCH CONFIRMED REFEREES (using pooled HTTP client) ─────
API_BASE = "https://b0i2d55s30.execute-api.us-east-1.amazonaws.com/wrestling"
def fetch_referees(comp_id: int, style: str):
    url = (
        f"{API_BASE}/referee/getRefereeWSbasedUUIDs"
        f"?competition_UUID={comp_id}"
        f"&wrestling_style={urllib.parse.quote(style)}"
    )
    resp = http.request(
        "GET",
        url,
        timeout=urllib3.Timeout(connect=2.0, read=5.0),
        headers={"Accept": "application/json"}
    )
    if resp.status != 200:
        raise RuntimeError(f"Referee API returned {resp.status}: {resp.data}")
    payload = json.loads(resp.data.decode("utf-8"))
    ref_list = payload.get("body", payload)
    ids = [x["referee_UUID"] for x in ref_list]
    return tuple(ids[:3]) if len(ids) >= 3 else None

# ─── WEIGHT CATEGORIES ───────────────────────────────────
WEIGHT_CATS = {
    "Greco Roman": ["55","60","63","67","72","77","82","87","97","130"],
    "Freestyle":   ["57","61","65","70","74","79","86","92","97","125"],
    "Women":       ["50","53","55","57","59","62","65","68","72","76"],
}

# ─── SQL TEMPLATES ─────────────────────────────────────
SQL_EXISTS_BRONZE = """
SELECT 1 FROM competitions_fights
 WHERE competition_UUID=%s
   AND competition_round='Bronze'
   AND competition_fight_weight_category=%s
LIMIT 1
"""

SQL_FINAL = """
SELECT wrestler_UUID_red, wrestler_UUID_blue
FROM competitions_fights
WHERE competition_UUID=%s
  AND wrestling_style=%s
  AND competition_fight_weight_category=%s
  AND competition_round='Final'
LIMIT 1
"""

SQL_SEMI = """
SELECT wrestler_UUID_red, wrestler_UUID_blue, wrestler_UUID_winner
FROM competitions_fights
WHERE competition_UUID=%s
  AND competition_round='Round 2'
  AND competition_fight_weight_category=%s
  AND (wrestler_UUID_red=%s OR wrestler_UUID_blue=%s)
LIMIT 1
"""

SQL_QUARTER = """
SELECT wrestler_UUID_red, wrestler_UUID_blue
FROM competitions_fights
WHERE competition_UUID=%s
  AND competition_round='Round 4'
  AND competition_fight_weight_category=%s
  AND wrestler_UUID_winner=%s
LIMIT 1
"""

SQL_NEXT_ORDER = """
SELECT COALESCE(MAX(competition_fight_order_number),0)+1 AS nxt
FROM competitions_fights
WHERE competition_UUID=%s
"""

SQL_INSERT = """
INSERT INTO competitions_fights (
  competition_UUID, competition_round, competition_fight_order_number,
  wrestling_style, competition_fight_weight_category,
  referee_UUID_1, referee_UUID_2, referee_UUID_3,
  wrestling_club_UUID_red, wrestling_club_UUID_blue,
  coach_UUID_red, coach_UUID_blue,
  wrestler_UUID_red, wrestler_UUID_blue,
  wrestler_points_red, wrestler_points_blue, wrestler_UUID_winner
) VALUES (
  %s, 'Bronze', %s,
  %s, %s,
  %s, %s, %s,
  %s, %s,
  %s, %s,
  %s, %s,
  0, 0, NULL
)
"""

# ─── HELPERS ────────────────────────────────────────────
def club_and_coach(cur, wid):
    cur.execute(
        """
        SELECT w.coach_UUID, c.wrestling_club_UUID
        FROM wrestlers w
        JOIN coaches c ON c.coach_UUID=w.coach_UUID
        WHERE w.wrestler_UUID=%s
        """,
        (wid,)
    )
    return cur.fetchone() or {"coach_UUID": None, "wrestling_club_UUID": None}

def bronze_pair(cur, comp_id, style, kg, finalist):
    # semifinal losing opponent
    cur.execute(SQL_SEMI, (comp_id, kg, finalist, finalist))
    semi = cur.fetchone()
    if not semi:
        return None
    loser1 = (semi["wrestler_UUID_red"]
              if semi["wrestler_UUID_winner"] != semi["wrestler_UUID_red"]
              else semi["wrestler_UUID_blue"])
    # quarterfinal losing opponent
    cur.execute(SQL_QUARTER, (comp_id, kg, finalist))
    q = cur.fetchone()
    if not q:
        return None
    loser2 = q["wrestler_UUID_red"] if q["wrestler_UUID_red"] != finalist else q["wrestler_UUID_blue"]
    if loser1 == loser2 or loser2 == finalist:
        return None
    return loser1, loser2

# ─── LAMBDA HANDLER ─────────────────────────────────────
def lambda_handler(event, context):
    # 1) Parse request body
    body = event["body"]
    competition_UUID = body.get("competition_UUID")
    wrestling_style = body.get("wrestling_style")

    # 2) Validate
    if (not isinstance(competition_UUID, int)
        or not isinstance(wrestling_style, str)
        or wrestling_style not in WEIGHT_CATS):
        return {
            "statusCode": 400,
            "body": json.dumps({"error":"Invalid competition_UUID or wrestling_style"})
        }

    # 3) Fetch referees
    refs = fetch_referees(competition_UUID, wrestling_style)
    if not refs:
        return {
            "statusCode": 400,
            "body": json.dumps({"error":"<3 arbitri confirmați"})
        }
    ref1, ref2, ref3 = refs

    rows = []
    try:
        with db().cursor() as cur:
            # next insertion order
            cur.execute(SQL_NEXT_ORDER, (competition_UUID,))
            order = cur.fetchone()["nxt"]

            # for each weight category
            for kg in WEIGHT_CATS[wrestling_style]:
                # skip if Bronze already generated
                cur.execute(SQL_EXISTS_BRONZE, (competition_UUID, kg))
                if cur.fetchone():
                    continue

                # get finalists
                cur.execute(SQL_FINAL, (competition_UUID, wrestling_style, kg))
                final = cur.fetchone()
                if not final:
                    continue
                finalists = (final["wrestler_UUID_red"], final["wrestler_UUID_blue"])

                # build bronze pairs
                pairs = []
                for f in finalists:
                    bp = bronze_pair(cur, competition_UUID, wrestling_style, kg, f)
                    if bp:
                        pairs.append(bp)
                if len(pairs) != 2:
                    continue

                # prepare insert rows
                for red, blue in pairs:
                    r = club_and_coach(cur, red)
                    b = club_and_coach(cur, blue)
                    rows.append((
                        competition_UUID,
                        order,
                        wrestling_style,
                        kg,
                        ref1, ref2, ref3,
                        r["wrestling_club_UUID"], b["wrestling_club_UUID"],
                        r["coach_UUID"], b["coach_UUID"],
                        red, blue
                    ))
                    order += 1

            # perform batch insert
            if rows:
                cur.executemany(SQL_INSERT, rows)

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

    return {
        "statusCode": 200,
        "body": json.dumps({"inserted_bronze_fights": len(rows)})
    }
