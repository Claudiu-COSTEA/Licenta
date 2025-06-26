import json
import pymysql

# RDS connection settings
DB_HOST     = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER     = "admin"
DB_PASSWORD = "admin123"
DB_NAME     = "wrestlingMobileAppDatabase"

_connection = None
def get_connection():
    global _connection
    if _connection is None or not _connection.open:
        _connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            connect_timeout=5,
            autocommit=True,
            cursorclass=pymysql.cursors.DictCursor
        )
    return _connection

def lambda_handler(event, context):
    """
    Expects event['body'] to be a parsed JSON object, e.g.:
      {
        "competition_UUID": 4,
        "competition_status": "Confirmed"
      }
    (As produced by your VTL: { "body": $input.json('$') } )
    """
    try:
        # body is already a dict thanks to your mapping template
        body = event.get("body") or {}
        comp_id    = body.get("competition_UUID")
        new_status = body.get("competition_status")

        # Validate inputs
        if comp_id is None or new_status not in ("Pending", "Confirmed", "Postponed"):
            return {
                "statusCode": 400,
                "body": json.dumps({
                    "error": "Must provide valid competition_UUID and competition_status"
                })
            }

        # Perform update
        conn = get_connection()
        with conn.cursor() as cur:
            sql = """
                UPDATE competitions
                   SET competition_status = %s
                 WHERE competition_UUID = %s
            """
            cur.execute(sql, (new_status, comp_id))
            if cur.rowcount == 0:
                return {
                    "statusCode": 404,
                    "body": json.dumps({"error": "Competition not found"})
                }

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Status updated successfully"})
        }

    except pymysql.MySQLError as err:
        print("MySQL error:", err)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Database error"})
        }

    except Exception as exc:
        print("Unhandled exception:", exc)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal server error"})
        }
