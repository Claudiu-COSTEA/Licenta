import json, random, urllib.request, urllib.parse
import pymysql

# ─── CONFIG GLOBAL ───────────────────────────────────────────
COMP_ID  = 1
STYLE    = "Greco Roman"
CATS_KG  = [60,63,67,72,77,82,87,92,97,130]

DB_HOST  = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER  = "admin"
DB_PASS  = "admin123"
DB_NAME  = "wrestlingMobileAppDatabase"

BASE  = "https://b0i2d55s30.execute-api.us-east-1.amazonaws.com/wrestling"
API_REF = (f"{BASE}/referee/getRefereeWSbasedUUIDs"
           f"?competition_UUID={COMP_ID}"
           f"&wrestling_style={urllib.parse.quote(STYLE)}")

# ─── DB connection (re-usable) ───────────────────────────────
_conn=None
def db():
    global _conn
    if _conn and _conn.open:
        return _conn
    _conn = pymysql.connect(host=DB_HOST,user=DB_USER,password=DB_PASS,
                            database=DB_NAME,autocommit=True,
                            cursorclass=pymysql.cursors.DictCursor)
    return _conn

# ─── Helpers rundă / perechi ─────────────────────────────────
def round_for_n(n:int)->str:
    """64-33→R32, 32-17→R16, 16-9→R8, 8-5→R4, 4-3→R2, 2-1→Final"""
    if n <= 2:
        return "Final"
    p=1
    while p < n: p*=2
    size=max(p//2,2)
    return "Round 2" if size==2 else f"Round {size}"

def largest_pow_two(n:int)->int:
    p=1
    while p*2<=n: p*=2
    return p

def prelim_pairs(lst):
    random.shuffle(lst)
    n=len(lst)
    if n < 2:
        return []
    if n == 2:                      # finala
        return [(lst[0], lst[1])]
    rng = n if (n&(n-1))==0 else (n-largest_pow_two(n))*2
    return [(lst[i], lst[i+1]) for i in range(0, rng, 2)]

def dedupe(rows):
    seen=set(); out=[]
    for r in rows:
        uid=r["wrestler_UUID"]
        if uid not in seen:
            seen.add(uid); out.append(r)
    return out

# ─── SQL fragments ──────────────────────────────────────────
SQL_RD_OK = """
SELECT CAST(SUBSTRING(TRIM(competition_round),7) AS UNSIGNED) AS r
FROM competitions_fights
WHERE competition_UUID=%s
  AND wrestling_style=%s
  AND competition_fight_weight_category=%s
  AND competition_round NOT IN ('Final')
GROUP BY competition_round
HAVING COUNT(*) = SUM(wrestler_UUID_winner IS NOT NULL)
ORDER BY r ASC
LIMIT 1;
"""

SQL_WIN = """
SELECT cf.wrestler_UUID_winner AS wrestler_UUID,
       c.coach_UUID,
       c.wrestling_club_UUID
FROM competitions_fights cf
JOIN wrestlers w ON w.wrestler_UUID = cf.wrestler_UUID_winner
JOIN coaches  c ON c.coach_UUID     = w.coach_UUID
WHERE cf.competition_UUID = %s
  AND cf.wrestling_style  = %s
  AND cf.competition_fight_weight_category = %s
  AND TRIM(cf.competition_round) = %s
  AND cf.wrestler_UUID_winner IS NOT NULL;
"""

SQL_BYE = """
SELECT ci.recipient_UUID AS wrestler_UUID,
       c.coach_UUID,
       c.wrestling_club_UUID
FROM competitions_invitations ci
JOIN wrestlers w ON w.wrestler_UUID = ci.recipient_UUID
JOIN coaches  c ON c.coach_UUID     = w.coach_UUID
WHERE ci.competition_UUID=%s
  AND ci.weight_category=%s
  AND w.wrestling_style=%s
  AND ci.referee_verification='Confirmed'
  AND ci.invitation_response_date IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM competitions_fights f
        WHERE f.competition_UUID = ci.competition_UUID
          AND f.competition_fight_weight_category = ci.weight_category
          AND (f.wrestler_UUID_red  = ci.recipient_UUID
            OR f.wrestler_UUID_blue = ci.recipient_UUID)
  );
"""

SQL_EXISTS_ROUND = """
SELECT 1
FROM competitions_fights
WHERE competition_UUID=%s
  AND wrestling_style=%s
  AND competition_fight_weight_category=%s
  AND TRIM(competition_round)=TRIM(%s)
LIMIT 1;
"""

SQL_COUNT = "SELECT COUNT(*) AS n FROM competitions_fights WHERE competition_UUID=%s;"

SQL_INS = """
INSERT INTO competitions_fights
 (competition_UUID, competition_round, competition_fight_order_number,
  wrestling_style, competition_fight_weight_category,
  referee_UUID_1, referee_UUID_2, referee_UUID_3,
  wrestling_club_UUID_red, wrestling_club_UUID_blue,
  coach_UUID_red, coach_UUID_blue,
  wrestler_UUID_red, wrestler_UUID_blue,
  wrestler_points_red, wrestler_points_blue, wrestler_UUID_winner)
VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
"""

# ─── API helper pentru arbitri ───────────────────────────────
def jget(url):
    with urllib.request.urlopen(url, timeout=5) as r:
        return json.load(r)

def referee_ids():
    ids=[x["referee_UUID"] for x in jget(API_REF)["body"]]
    if len(ids)<3:
        raise RuntimeError("<3 arbitri confirmaţi")
    return ids[:3]

# ─── colectează sportivii activi (winners + bye) ─────────────
def collect_active(cur, kg:str):
    cur.execute(SQL_RD_OK,(COMP_ID,STYLE,kg))
    row = cur.fetchone()
    winners=[]
    if row:
        cur.execute(SQL_WIN,(COMP_ID,STYLE,kg,f"Round {row['r']}"))
        winners=list(cur.fetchall())
    cur.execute(SQL_BYE,(COMP_ID,kg,STYLE))
    byes=list(cur.fetchall())
    return dedupe(winners + byes)

# ─── Lambda handler ─────────────────────────────────────────
def lambda_handler(event, context):
    try:
        ref1,ref2,ref3 = referee_ids()
    except Exception as exc:
        return {"statusCode":502,"body":json.dumps({"error":str(exc)})}

    with db().cursor() as cur:
        cur.execute(SQL_COUNT,(COMP_ID,))
        order = cur.fetchone()["n"] + 1

    inserts=[]

    for kg in CATS_KG:
        with db().cursor() as cur:
            wrestlers = collect_active(cur, str(kg))

        if len(wrestlers) < 2:
            continue

        rnd = round_for_n(len(wrestlers))

        # dacă Final sau runda respectivă există deja → skip
        with db().cursor() as cur:
            cur.execute(SQL_EXISTS_ROUND,(COMP_ID,STYLE,str(kg),rnd))
            if cur.fetchone():
                continue

        # listă perechi (pentru n==2 primeşti un singur tuple)
        pairs = prelim_pairs(wrestlers)

        for red, blue in pairs:
            inserts.append((
                COMP_ID, rnd, order, STYLE, str(kg),
                ref1, ref2, ref3,
                red["wrestling_club_UUID"],  blue["wrestling_club_UUID"],
                red["coach_UUID"],           blue["coach_UUID"],
                red["wrestler_UUID"],        blue["wrestler_UUID"],
                0,0,None
            ))
            order += 1

    if not inserts:
        return {"statusCode":404,
                "body":json.dumps({"message":"nicio pereche generată"})}

    try:
        with db().cursor() as cur:
            cur.executemany(SQL_INS,inserts)
    except Exception as exc:
        return {"statusCode":500,
                "body":json.dumps({"error":str(exc)})}

    return {"statusCode":200,
            "body":json.dumps({"inserted_fights":len(inserts)})}
