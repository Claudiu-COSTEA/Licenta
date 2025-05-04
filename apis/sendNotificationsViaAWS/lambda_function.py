import json
import pymysql
import requests
from datetime import datetime

# — RDS connection settings —
DB_HOST     = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER     = "admin"
DB_PASSWORD = "admin123"
DB_NAME     = "wrestlingMobileAppDatabase"

# — FCM (Firebase Cloud Messaging) server key —
# Replace with your actual key from the Firebase console
FCM_SERVER_KEY = "AIzaSyBbbpq-P9vhkUpzvreBoGC4bONPf561gr4"
FCM_URL        = "https://fcm.googleapis.com/fcm/send"

# Reuse one connection per container
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

def lambda_handler(event, context):
    """
    Scheduled Lambda (triggered by EventBridge once per day at midnight UTC),
    which notifies wrestling clubs one day before their invitation deadline.
    """
    # 1) Compute today's date (UTC) as 'YYYY-MM-DD'
    today = datetime.utcnow().strftime('%Y-%m-%d')

    # 2) Query for invitations pending whose deadline is exactly tomorrow
    sql = """
        SELECT
          ci.recipient_UUID,
          u.fcm_token,
          wc.wrestling_club_city  AS city,
          ci.competition_UUID
        FROM competitions_invitations ci
        JOIN users u
          ON u.user_UUID = ci.recipient_UUID
        JOIN wrestling_club wc
          ON wc.wrestling_club_UUID = ci.recipient_UUID
        WHERE ci.invitation_status = 'Pending'
          AND DATE(ci.invitation_deadline) = DATE_ADD(%s, INTERVAL 1 DAY);
    """
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute(sql, (today,))
            rows = cur.fetchall()
    except Exception as db_err:
        print("DB error:", db_err)
        return {"statusCode": 500, "body": json.dumps({"error": "DB query failed"})}

    headers = {
        'Authorization': f'key={FCM_SERVER_KEY}',
        'Content-Type':  'application/json'
    }

    notified = 0
    for r in rows:
        token   = r.get('fcm_token')
        city    = r.get('city')
        comp_id = r.get('competition_UUID')
        if not token:
            print(f"No FCM token for user {r.get('recipient_UUID')}, skipping.")
            continue

        # 3) Send the FCM notification
        payload = {
            'to': token,
            'notification': {
                'title': 'Termen invitație mâine',
                'body':  f"Invitație pentru clubul din {city} expiră mâine.",
            },
            'data': {
                'competition_uuid': comp_id
            }
        }
        try:
            resp = requests.post(FCM_URL, headers=headers, json=payload, timeout=5)
            resp.raise_for_status()
            notified += 1
        except Exception as fcm_err:
            print(f"FCM send error for token {token}: {fcm_err}")
            continue

        # 4) Update the invitation so we don't notify repeatedly
        try:
            with conn.cursor() as cur2:
                cur2.execute(
                    "UPDATE competitions_invitations "
                    "SET invitation_status = 'Postponed' "
                    "WHERE recipient_UUID = %s "
                    "  AND DATE(invitation_deadline) = DATE_ADD(%s, INTERVAL 1 DAY);",
                    (r['recipient_UUID'], today)
                )
        except Exception as upd_err:
            print("Error updating invitation status:", upd_err)

    return {
        'statusCode': 200,
        'body': json.dumps({'notified_count': notified})
    }
