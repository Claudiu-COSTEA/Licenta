import json
import pymysql

# ─── CONFIG ───────────────────────────────────────────────────
DB_HOST     = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER     = "admin"
DB_PASSWORD = "admin123"
DB_NAME     = "wrestlingMobileAppDatabase"

def get_db_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        autocommit=True,
        cursorclass=pymysql.cursors.DictCursor
    )

def lambda_handler(event, context):
    # 1) Grab the body as a dict (no json.loads)
    body = event.get("body") or {}

    # 2) Extract parameters
    wrestler_uuid = body.get("wrestler_UUID")
    doc_type      = body.get("type")
    url           = body.get("url")

    # 3) Validate
    if not isinstance(wrestler_uuid, int) or not isinstance(doc_type, str) or not isinstance(url, str):
        return {
            "statusCode": 400,
            "body": {
                "error": "Required: wrestler_UUID (int), type ('medical'|'license'), url (string)"
            },
        }

    # 4) Pick the right column
    if doc_type == "medical":
        column = "medical_document"
    elif doc_type == "license":
        column = "license_document"
    else:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid type; must be 'medical' or 'license'"})
        }

    # 5) Execute UPDATE
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            sql = f"UPDATE wrestlers SET {column} = %s WHERE wrestler_UUID = %s"
            cursor.execute(sql, (url, wrestler_uuid))
        # autocommit=True, no explicit commit needed
    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": f"DB update failed: {e}"}
        }
    finally:
        conn.close()

    # 6) Return success
    return {
        "statusCode": 200,
        "body": {
            "message": f"{column} updated",
            "wrestler_UUID": wrestler_uuid,
            "url": url
        }
    }
