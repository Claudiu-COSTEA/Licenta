import json, pymysql, urllib.parse, urllib.request

# ─── RDS  ───────────────────────────────────────────────────
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASS = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def db():
    return pymysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASS,
                           database=DB_NAME, autocommit=True,
                           cursorclass=pymysql.cursors.DictCursor)

# ─── API arbitri confirmaţi  ───────────────────────────────
API_BASE = "https://rhybb6zgsb.execute-api.us-east-1.amazonaws.com/wrestling"
def fetch_referees(comp_id: int, style: str):
    url = (f"{API_BASE}/referee/getRefereeWSbasedUUIDs"
           f"?competition_UUID={comp_id}"
           f"&wrestling_style={urllib.parse.quote(style)}")
    with urllib.request.urlopen(url, timeout=5) as r:
        data = json.load(r)
    ids = [x["referee_UUID"] for x in (data["body"] if isinstance(data, dict) else data)]
    return tuple(ids[:3]) if len(ids) >= 3 else None

# ─── SQL templates  ───────────────────────────────────────
SQL_FINAL = """SELECT wrestler_UUID_red, wrestler_UUID_blue
                 FROM competitions_fights
                WHERE competition_UUID=%s AND wrestling_style=%s
                  AND competition_fight_weight_category=%s
                  AND competition_round='Final' LIMIT 1"""

SQL_SEMI = """SELECT wrestler_UUID_red, wrestler_UUID_blue, wrestler_UUID_winner
                FROM competitions_fights
               WHERE competition_UUID=%s AND competition_round='Round 2'
                 AND competition_fight_weight_category=%s
                 AND (wrestler_UUID_red=%s OR wrestler_UUID_blue=%s) LIMIT 1"""

SQL_QUARTER = """SELECT wrestler_UUID_red, wrestler_UUID_blue
                   FROM competitions_fights
                  WHERE competition_UUID=%s AND competition_round='Round 4'
                    AND competition_fight_weight_category=%s
                    AND wrestler_UUID_winner=%s LIMIT 1"""

SQL_EXISTS_BRONZE = """SELECT 1 FROM competitions_fights
                        WHERE competition_UUID=%s AND competition_round='Bronze'
                          AND competition_fight_weight_category=%s LIMIT 1"""

SQL_NEXT_ORDER = """SELECT COALESCE(MAX(competition_fight_order_number),0)+1 nxt
                     FROM competitions_fights WHERE competition_UUID=%s"""

SQL_INSERT = """INSERT INTO competitions_fights
 (competition_UUID, competition_round, competition_fight_order_number,
  wrestling_style, competition_fight_weight_category,
  referee_UUID_1, referee_UUID_2, referee_UUID_3,
  wrestling_club_UUID_red, wrestling_club_UUID_blue,
  coach_UUID_red, coach_UUID_blue,
  wrestler_UUID_red, wrestler_UUID_blue,
  wrestler_points_red, wrestler_points_blue, wrestler_UUID_winner)
VALUES (%s,'Bronze',%s,%s,%s,
        %s,%s,%s,
        %s,%s,%s,%s,
        %s,%s,0,0,NULL)"""

# helper club+coach
def club_and_coach(cur, wrestler_id):
    cur.execute("""SELECT w.coach_UUID, c.wrestling_club_UUID
                     FROM wrestlers w
                     JOIN coaches c ON c.coach_UUID=w.coach_UUID
                    WHERE w.wrestler_UUID=%s""", (wrestler_id,))
    return cur.fetchone() or {"coach_UUID": None, "wrestling_club_UUID": None}

# pereche Bronze pentru un finalist (8-sportivi)
def bronze_pair(cur, comp, style, kg, finalist):
    # semifinalist pierzător
    cur.execute(SQL_SEMI, (comp, kg, finalist, finalist))
    semi = cur.fetchone()
    if not semi:
        return None
    semi_loser = (semi["wrestler_UUID_red"]
                  if semi["wrestler_UUID_winner"] != semi["wrestler_UUID_red"]
                  else semi["wrestler_UUID_blue"])

    # pierzătorul din sfertul câştigat de finalist
    cur.execute(SQL_QUARTER, (comp, kg, finalist))
    q = cur.fetchone()
    if not q:
        return None
    quarter_loser = q["wrestler_UUID_red"] if q["wrestler_UUID_red"] != finalist else q["wrestler_UUID_blue"]

    if semi_loser == quarter_loser or quarter_loser == finalist:
        return None
    return semi_loser, quarter_loser

# ─── Lambda  ───────────────────────────────────────────────
def lambda_handler(event, ctx):
    # parametrii direct
    try:
        COMP_ID = int(event["competition_uuid"])
        STYLE   = str(event["wrestling_style"])
        KG      = str(event["weight_category"])
    except (KeyError, ValueError, TypeError):
        return {"statusCode":400,
                "body":json.dumps({"error":
                    "competition_uuid, wrestling_style, weight_category obligatorii"})}

    refs = fetch_referees(COMP_ID, STYLE)
    if not refs:
        return {"statusCode":400,
                "body":json.dumps({"error":"<3 arbitri confirmaţi"})}
    REF1, REF2, REF3 = refs

    with db().cursor() as cur:
        cur.execute(SQL_EXISTS_BRONZE, (COMP_ID, KG))
        if cur.fetchone():
            return {"statusCode":200,
                    "body":json.dumps({"message":"Bronzele există deja"})}

        cur.execute(SQL_FINAL, (COMP_ID, STYLE, KG))
        final = cur.fetchone()
        if not final:
            return {"statusCode":400,
                    "body":json.dumps({"error":"Finala nu există"})}

        finalists = (final["wrestler_UUID_red"], final["wrestler_UUID_blue"])

        pairs=[]
        for f in finalists:
            bp = bronze_pair(cur, COMP_ID, STYLE, KG, f)
            if bp:
                pairs.append(bp)

        if len(pairs)!=2:
            return {"statusCode":400,
                    "body":json.dumps({"error":"Perechile Bronze nu pot fi determinate"})}

        cur.execute(SQL_NEXT_ORDER,(COMP_ID,))
        order = cur.fetchone()["nxt"]

        rows=[]
        for red, blue in pairs:
            r = club_and_coach(cur, red)
            b = club_and_coach(cur, blue)
            rows.append((COMP_ID, order, STYLE, KG,
                         REF1, REF2, REF3,
                         r["wrestling_club_UUID"], b["wrestling_club_UUID"],
                         r["coach_UUID"], b["coach_UUID"],
                         red, blue))
            order += 1

        cur.executemany(SQL_INSERT, rows)

    return {"statusCode":200,
            "body":json.dumps({"inserted_bronze_fights": len(rows)})}
