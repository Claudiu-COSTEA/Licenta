import json
import pymysql
import boto3
import unicodedata
from fpdf import FPDF

# ─── SETTINGS ─────────────────────────────────────────────────
DB_HOST   = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER   = "admin"
DB_PASS   = "admin123"
DB_NAME   = "wrestlingMobileAppDatabase"

S3_BUCKET = "wrestlingdocumentsbucket"
PDF_KEY_TEMPLATE   = "reports/{date}_{name}_podium.pdf"

WEIGHT_CATS = {
    "Greco Roman": ["55","60","63","67","72","77","82","87","97","130"],
    "Freestyle":   ["57","61","65","70","74","79","86","92","97","125"],
    "Women":       ["50","53","55","57","59","62","65","68","72","76"],
}

# ─── RDS CONNECTION (reusable) ───────────────────────────────
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

def strip_diacritics(text: str) -> str:
    nfkd = unicodedata.normalize('NFKD', text)
    return ''.join(c for c in nfkd if unicodedata.category(c) != 'Mn')

def get_details(cur, uid):
    cur.execute("SELECT user_full_name FROM users WHERE user_UUID=%s", (uid,))
    name = strip_diacritics(cur.fetchone().get("user_full_name",""))
    cur.execute("SELECT coach_UUID FROM wrestlers WHERE wrestler_UUID=%s", (uid,))
    coach_id = cur.fetchone().get("coach_UUID")
    cur.execute("SELECT user_full_name FROM users WHERE user_UUID=%s", (coach_id,))
    coach = strip_diacritics(cur.fetchone().get("user_full_name",""))
    cur.execute("SELECT wrestling_club_UUID FROM coaches WHERE coach_UUID=%s", (coach_id,))
    club_id = cur.fetchone().get("wrestling_club_UUID")
    cur.execute("SELECT user_full_name FROM users WHERE user_UUID=%s", (club_id,))
    club = strip_diacritics(cur.fetchone().get("user_full_name",""))
    cur.execute("SELECT wrestling_club_city FROM wrestling_club WHERE wrestling_club_UUID=%s", (club_id,))
    city = strip_diacritics(cur.fetchone().get("wrestling_club_city",""))
    return name, coach, club, city

# ─── FETCH PODIUM DATA ────────────────────────────────────────
def fetch_podium(comp_id:int):
    podium=[]
    conn = db()
    for style,cats in WEIGHT_CATS.items():
        for kg in cats:
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT wrestler_UUID_red, wrestler_UUID_blue, wrestler_UUID_winner"
                    " FROM competitions_fights"
                    " WHERE competition_UUID=%s"
                    " AND wrestling_style=%s"
                    " AND competition_fight_weight_category=%s"
                    " AND competition_round='Final' LIMIT 1",
                    (comp_id, style, kg)
                )
                f=cur.fetchone()
                if not f: continue
                gold_id   = f["wrestler_UUID_winner"]
                silver_id = f["wrestler_UUID_red"] if f["wrestler_UUID_winner"]==f["wrestler_UUID_blue"] else f["wrestler_UUID_blue"]
                cur.execute(
                    "SELECT wrestler_UUID_red, wrestler_UUID_blue"
                    " FROM competitions_fights"
                    " WHERE competition_UUID=%s"
                    " AND wrestling_style=%s"
                    " AND competition_fight_weight_category=%s"
                    " AND competition_round='Bronze'",
                    (comp_id, style, kg)
                )
                bronzes = cur.fetchall()
                b_ids=[]
                for b in bronzes:
                    b_ids += [b["wrestler_UUID_red"], b["wrestler_UUID_blue"]]
                b_ids = list(dict.fromkeys(b_ids))[:2]
                gold    = get_details(cur, gold_id)
                silver  = get_details(cur, silver_id)
                bronze1 = get_details(cur, b_ids[0]) if len(b_ids)>0 else ("","","","")
                bronze2 = get_details(cur, b_ids[1]) if len(b_ids)>1 else ("","","","")
                for medal,det in [("Aur",gold),("Argint",silver),("Bronz",bronze1),("Bronz",bronze2)]:
                    name,coach,club,city = det
                    podium.append({
                        "stil": strip_diacritics(style),
                        "kg": kg,
                        "medalie": medal,
                        "sportiv": name,
                        "antrenor": coach,
                        "club": club,
                        "oras": city
                    })
    return podium

def build_filename(cur, comp_id:int):
    cur.execute("SELECT competition_name, competition_start_date FROM competitions WHERE competition_UUID=%s", (comp_id,))
    row = cur.fetchone() or {}
    name = strip_diacritics(row.get("competition_name","comp"))
    dt = row.get("competition_start_date")
    date_str = dt.strftime("%Y%m%d") if dt else ""
    safe = name.replace(' ', '_')
    return f"{date_str}_{safe}_podium.pdf"

def make_pdf(podium, filepath):
    pdf=FPDF('L','mm','A4')
    pdf.add_page()
    pdf.set_font("Arial","B",16)
    pdf.cell(0,10,"Podium Competitie",ln=True,align="C")
    pdf.ln(6)
    headers=["Stil","Categorie","Medalie","Sportiv","Antrenor","Club","Oras"]
    widths=[30,20,20,50,50,50,30]
    pdf.set_font("Arial","B",12)
    for i,h in enumerate(headers): pdf.cell(widths[i],10,h,border=1,align="C")
    pdf.ln()
    pdf.set_font("Arial","",11)
    for row in podium:
        for i,key in enumerate(["stil","kg","medalie","sportiv","antrenor","club","oras"]):
            pdf.cell(widths[i],8,str(row[key]),border=1)
        pdf.ln()
    pdf.output(filepath)

# ─── LAMBDA HANDLER ─────────────────────────────────────────
def lambda_handler(event, context):
    body = event.get('body') or {}
    comp_id = body.get('competition_UUID')
    if not isinstance(comp_id,int):
        return {"statusCode":400,"body":json.dumps({"error":"competition_UUID(int) required"})}

    conn = db()
    podium = fetch_podium(comp_id)
    cursor = conn.cursor()
    filename = build_filename(cursor, comp_id)
    tmp = f"/tmp/{filename}"
    make_pdf(podium,tmp)

    s3 = boto3.client("s3")
    date_part, name_part, _ = filename.split('_',2)
    key = PDF_KEY_TEMPLATE.format(date=date_part, name=name_part)
    s3.upload_file(tmp,S3_BUCKET,key,ExtraArgs={"ContentType":"application/pdf"})
    url = s3.generate_presigned_url("get_object",Params={"Bucket":S3_BUCKET,"Key":key},ExpiresIn=3600)

    # update URL and status to Finished
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE competitions SET competition_results=%s, competition_status='Finished' WHERE competition_UUID=%s",
            (url, comp_id)
        )
        conn.commit()

    return {"statusCode":200,"body":json.dumps({"pdfUrl":url})}
