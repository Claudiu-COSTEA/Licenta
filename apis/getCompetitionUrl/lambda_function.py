import json
import pymysql

# Database connection details
DB_HOST     = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER     = "admin"
DB_PASSWORD = "admin123"
DB_NAME     = "wrestlingMobileAppDatabase"

def connect_to_db():
    """Establish (and return) a pymysql connection."""
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        autocommit=True,
        cursorclass=pymysql.cursors.DictCursor
    )

def lambda_handler(event, context):
    # 1) Grab competition_UUID directly from event
    #    (e.g. if invoked as Lambda(arg) or via GET ?competition_UUID=1)
    try:
        comp_id = int(event.get("competition_UUID"))
    except Exception:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Field competition_UUID (int) is required"})
        }

    # 2) Query the DB
    conn = connect_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT competition_results FROM competitions WHERE competition_UUID=%s",
                (comp_id,)
            )
            row = cur.fetchone()
    finally:
        conn.close()

    # 3) If no URL found, 404
    if not row or not row.get("competition_results"):
        return {
            "statusCode": 404,
            "body": json.dumps({"error": "PDF URL not found for competition"})
        }

    # 4) Success—return the URL
    return {
        "statusCode": 200,
        "body": json.dumps({"url": row["competition_results"]})
    }
