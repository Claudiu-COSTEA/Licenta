import json
import pymysql
import requests
from datetime import datetime, timedelta, timezone

# Google Auth imports for HTTP v1
from google.oauth2 import service_account
from google.auth.transport.requests import Request

# — RDS connection settings (hard-coded) —
DB_HOST     = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER     = "admin"
DB_PASSWORD = "admin123"
DB_NAME     = "wrestlingMobileAppDatabase"

# Firebase project & FCM HTTP v1 endpoint
PROJECT_ID  = "wrestling-mobile-application"
FCM_URL     = f"https://fcm.googleapis.com/v1/projects/{PROJECT_ID}/messages:send"

# OAuth scope for FCM HTTP v1 API
SCOPES = ["https://www.googleapis.com/auth/firebase.messaging"]

# Path to your service-account JSON (bundled next to this file)
SERVICE_ACCOUNT_FILE = "service-account.json"

# Reuse one DB connection per container
_connection = None
def get_connection():
    global _connection
    if _connection is None or not _connection.open:
        _connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True
        )
    return _connection

def get_fcm_access_token():
    """
    Load service-account credentials and refresh to get an OAuth2 token.
    """
    creds = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE,
        scopes=SCOPES
    )
    creds.refresh(Request())
    return creds.token

def lambda_handler(event, context):
    """
    Scheduled Lambda (triggered once per day by EventBridge),
    which sends FCM notifications one day before each invitation_deadline,
    including the competition name in the notification. Returns success=true.
    """
    # 1) Compute tomorrow's date (UTC)
    now_utc      = datetime.now(timezone.utc)
    tomorrow     = (now_utc + timedelta(days=1)).date()
    tomorrow_str = tomorrow.strftime("%Y-%m-%d")
    print(f"[DEBUG] querying invitations with deadline on {tomorrow_str}")

    # 2) Fetch pending invitations due tomorrow, with competition name
    select_sql = """
        SELECT
          ci.recipient_UUID,
          u.fcm_token,
          wc.wrestling_club_city AS city,
          ci.competition_UUID,
          c.competition_name
        FROM competitions_invitations AS ci
        JOIN users AS u
          ON u.user_UUID = ci.recipient_UUID
        LEFT JOIN wrestling_club AS wc
          ON wc.wrestling_club_UUID = ci.recipient_UUID
        JOIN competitions AS c
          ON c.competition_UUID = ci.competition_UUID
        WHERE ci.invitation_status = 'Pending'
          AND DATE(ci.invitation_deadline) = %s;
    """
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute(select_sql, (tomorrow_str,))
            rows = cur.fetchall()
    except Exception as e:
        print("[ERROR] DB query failed:", repr(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "DB query failed"})
        }

    print(f"[DEBUG] found {len(rows)} invitations to notify")

    # 3) Obtain FCM access token
    try:
        access_token = get_fcm_access_token()
    except Exception as e:
        print("[ERROR] FCM auth failed:", repr(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "FCM auth failed"})
        }

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type":  "application/json; UTF-8"
    }

    # 4) Send notifications
    for r in rows:
        token = r.get("fcm_token")
        if not token:
            print(f"[WARN] missing token for user {r['recipient_UUID']}, skipping")
            continue

        comp_name = r.get("competition_name", "competiție")
        message = {
            "message": {
                "token": token,
                "notification": {
                    "title": f"Invitație: {comp_name}",
                    "body":  f"Deadline-ul pentru „{comp_name}” expiră mâine."
                }
            }
        }

        try:
            resp = requests.post(FCM_URL, headers=headers, json=message, timeout=5)
            print(f"[FCM] to={token} status={resp.status_code}, body={resp.text}")
            resp.raise_for_status()
        except Exception as err:
            print(f"[ERROR] Failed sending to {token}: {err}")

    # 5) Return simple success response
    return {
        "statusCode": 200,
        "body": json.dumps({"success": True})
    }
