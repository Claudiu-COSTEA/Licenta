import json
import random
import urllib.request
import urllib.parse
import pymysql
from datetime import datetime

# ─── CONFIG ─────────────────────────────────────────────────────
DB_HOST  = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER  = "admin"
DB_PASS  = "admin123"
DB_NAME  = "wrestlingMobileAppDatabase"

BASE_URL = "https://b0i2d55s30.execute-api.us-east-1.amazonaws.com/wrestling"

WEIGHT_CATS = {
    "Freestyle":   ["57","61","65","70","74","79","86","92","97","125"],
    "Greco Roman": ["55","60","63","67","72","77","82","87","97","130"],
    "Women":       ["50","53","55","57","59","62","65","68","72","76"],
}

# ─── RDS CONNECTION (reusable) ─────────────────────────────────
_conn = None
def db():
    global _conn
    if _conn and _conn.open:
        return _conn
    _conn = pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        autocommit=True,
        cursorclass=pymysql.cursors.DictCursor
    )
    return _conn

# ─── FETCH 3 REFEREES FOR STYLE ──────────────────────────────────
def fetch_referees(comp_id: int, style: str):
    url = (
        f"{BASE_URL}/referee/getRefereeWSbasedUUIDs"
        f"?competition_UUID={comp_id}"
        f"&wrestling_style={urllib.parse.quote(style)}"
    )
    with urllib.request.urlopen(url, timeout=5) as r:
        payload = json.load(r)
    ids = [x["referee_UUID"] for x in payload["body"]]
    if len(ids) < 3:
        raise RuntimeError(f"Less than 3 referees for style={style}")
    return ids[:3]

# ─── ROUND & PAIRING LOGIC ──────────────────────────────────────
def round_for_n(n: int) -> str:
    if n <= 2:
        return "Final"
    p = 1
    while p < n:
        p *= 2
    size = max(p // 2, 2)
    return "Round 2" if size == 2 else f"Round {size}"

def largest_pow_two(n: int) -> int:
    p = 1
    while p * 2 <= n:
        p *= 2
    return p

def prelim_pairs(lst):
    random.shuffle(lst)
    n = len(lst)
    if n < 2:
        return []
    if n == 2:
        return [(lst[0], lst[1])]
    rng = n if (n & (n - 1)) == 0 else (n - largest_pow_two(n)) * 2
    return [(lst[i], lst[i+1]) for i in range(0, rng, 2)]

def dedupe(rows):
    seen = set()
    out = []
    for r in rows:
        uid = r["wrestler_UUID"]
        if uid not in seen:
            seen.add(uid)
            out.append(r)
    return out

# ─── SQL TEMPLATES ─────────────────────────────────────────────
SQL_LAST_ROUND = """
SELECT CAST(SUBSTRING(TRIM(competition_round),7) AS UNSIGNED) AS r
FROM competitions_fights
WHERE competition_UUID=%s
  AND wrestling_style=%s
  AND competition_fight_weight_category=%s
  AND competition_round!='Final'
GROUP BY competition_round
HAVING COUNT(*) = SUM(wrestler_UUID_winner IS NOT NULL)
ORDER BY r ASC
LIMIT 1;
"""

SQL_WINNERS = """
SELECT cf.wrestler_UUID_winner AS wrestler_UUID,
       c.coach_UUID,
       c.wrestling_club_UUID
FROM competitions_fights cf
JOIN wrestlers w ON w.wrestler_UUID = cf.wrestler_UUID_winner
JOIN coaches  c ON c.coach_UUID     = w.coach_UUID
WHERE cf.competition_UUID=%s
  AND cf.wrestling_style=%s
  AND cf.competition_fight_weight_category=%s
  AND TRIM(cf.competition_round)=%s
  AND cf.wrestler_UUID_winner IS NOT NULL;
"""

SQL_BYES = """
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
    SELECT 1 FROM competitions_fights f
    WHERE f.competition_UUID=ci.competition_UUID
      AND f.competition_fight_weight_category=ci.weight_category
      AND (f.wrestler_UUID_red=ci.recipient_UUID
        OR f.wrestler_UUID_blue=ci.recipient_UUID)
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

SQL_COUNT_FIGHTS = "SELECT COUNT(*) AS n FROM competitions_fights WHERE competition_UUID=%s;"

SQL_INSERT_FIGHT = """
INSERT INTO competitions_fights
  (competition_UUID,competition_round,competition_fight_order_number,
   wrestling_style,competition_fight_weight_category,
   referee_UUID_1,referee_UUID_2,referee_UUID_3,
   wrestling_club_UUID_red,wrestling_club_UUID_blue,
   coach_UUID_red,coach_UUID_blue,
   wrestler_UUID_red,wrestler_UUID_blue,
   wrestler_points_red,wrestler_points_blue,wrestler_UUID_winner)
VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s);
"""

def collect_active(cur, comp_id, style, kg):
    # 1) find last fully completed round
    cur.execute(SQL_LAST_ROUND, (comp_id, style, kg))
    row = cur.fetchone()

    winners = []
    if row:
        rnd = f"Round {row['r']}"
        cur.execute(SQL_WINNERS, (comp_id, style, kg, rnd))
        winners = cur.fetchall()    # could be list or tuple

    # 2) find byes
    cur.execute(SQL_BYES, (comp_id, kg, style))
    byes = cur.fetchall()           # could be list or tuple

    # 3) merge into a single Python list
    combined = []
    combined.extend(winners)        # works if winners is list or tuple
    combined.extend(byes)           # ditto

    # 4) dedupe and return
    return dedupe(combined)

# ─── LAMBDA HANDLER ───────────────────────────────────────────
def lambda_handler(event, context):
    # 1) Grab the body as a dict (no json.loads)
    body = event["body"]      # <= must already be a dict!
    
    # 2) Pull out your parameters
    competition_UUID = body["competition_UUID"]
    wrestling_style  = body["wrestling_style"]
    
    # 3) Validate inputs
    if not isinstance(competition_UUID, int) or not isinstance(wrestling_style, str):
        return {
            "statusCode": 400,
            "body": json.dumps({
                "error": "Provide integer competition_UUID and string wrestling_style"
            })
        }
    
    # 4) Determine styles to run
    if wrestling_style.lower() == "all":
        styles = list(WEIGHT_CATS.keys())
    else:
        styles = [wrestling_style]
    
    inserts = []
    try:
        # get next fight order number
        with db().cursor() as cur:
            cur.execute(SQL_COUNT_FIGHTS, (competition_UUID,))
            order = cur.fetchone()["n"] + 1
        
        # generate fights
        for style in styles:
            if style not in WEIGHT_CATS:
                continue
            ref1, ref2, ref3 = fetch_referees(competition_UUID, style)
            for kg in WEIGHT_CATS[style]:
                with db().cursor() as cur:
                    wrestlers = collect_active(cur, competition_UUID, style, kg)
                if len(wrestlers) < 2:
                    continue
                
                rnd = round_for_n(len(wrestlers))
                with db().cursor() as cur:
                    cur.execute(SQL_EXISTS_ROUND, (competition_UUID, style, kg, rnd))
                    if cur.fetchone():
                        continue
                
                for red, blue in prelim_pairs(wrestlers):
                    inserts.append((
                        competition_UUID, rnd, order, style, kg,
                        ref1, ref2, ref3,
                        red["wrestling_club_UUID"], blue["wrestling_club_UUID"],
                        red["coach_UUID"],            blue["coach_UUID"],
                        red["wrestler_UUID"],         blue["wrestler_UUID"],
                        0, 0, None
                    ))
                    order += 1
        
        if not inserts:
            return {
                "statusCode": 404,
                "body": json.dumps({"message": "No fights generated"})
            }
        
        # insert pairs
        with db().cursor() as cur:
            cur.executemany(SQL_INSERT_FIGHT, inserts)
    
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
    
    return {
        "statusCode": 200,
        "body": json.dumps({"inserted_fights": len(inserts)})
    }
