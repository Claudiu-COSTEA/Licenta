import json
import pymysql

# Detalii conexiune RDS
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASSWORD = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def connect_to_db():
    try:
        return pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
    except Exception as e:
        print(f"DB connection error: {e}")
        return None

def lambda_handler(event, context):
    """
    Așteaptă să primească event["body"] deja ca dict, conținând:
    {
      "competition_UUID": int,
      "competition_fight_UUID": int,
      "wrestler_points_red": int,
      "wrestler_points_blue": int,
      "wrestler_UUID_winner": int
    }
    """
    # 1) Extrage direct body-ul
    body = event.get("body")
    if not isinstance(body, dict):
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid request body; expected JSON object"})
        }

    # 2) Validare și conversie tipuri
    try:
        comp_id   = int(body["competition_UUID"])
        fight_id  = int(body["competition_fight_UUID"])
        pts_red   = int(body["wrestler_points_red"])
        pts_blue  = int(body["wrestler_points_blue"])
        winner_id = int(body["wrestler_UUID_winner"])
    except (KeyError, TypeError, ValueError) as e:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": f"Missing or invalid field: {e}"})
        }

    # 3) Conectare la baza de date
    conn = connect_to_db()
    if conn is None:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Could not connect to database"})
        }

    try:
        with conn.cursor() as cursor:
            sql = """
                UPDATE competitions_fights
                SET wrestler_points_red   = %s,
                    wrestler_points_blue  = %s,
                    wrestler_UUID_winner  = %s
                WHERE competition_UUID       = %s
                  AND competition_fight_UUID = %s
            """
            cursor.execute(sql, (pts_red, pts_blue, winner_id, comp_id, fight_id))
            conn.commit()

            if cursor.rowcount == 0:
                return {
                    "statusCode": 404,
                    "body": json.dumps({"message": "Fight not found"})
                }

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Fight updated successfully"})
        }

    except Exception as e:
        print(f"Update error: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
    finally:
        conn.close()
