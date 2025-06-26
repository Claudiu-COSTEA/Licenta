import pymysql

# --- Detalii RDS ---
DB_HOST     = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER     = "admin"
DB_PASSWORD = "admin123"
DB_NAME     = "wrestlingMobileAppDatabase"

def connect_to_db():
    """Establish connection to the RDS MySQL database."""
    try:
        return pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return None

def lambda_handler(event, context):
    """
    Lambda Proxy handler pentru GET /getUserFcmToken?user_UUID=<uuid>
    Răspunde cu JSON:
      - 200 + { fcm_token: ... }
      - 400 + { error: "user_UUID is required" }
      - 404 + { error: "User not found" }
      - 500 + { error: "..." }
    """
    user_uuid = event["user_UUID"]

    if not user_uuid:
        return {
            "statusCode": 400,
            "headers": { "Content-Type": "application/json" },
            "body": { "error": "user_UUID is required" }
        }

    # 2) Conectare la baza de date
    conn = connect_to_db()
    if conn is None:
        return {
            "statusCode": 500,
            "headers": { "Content-Type": "application/json" },
            "body": { "error": "Database connection failed" }
        }

    try:
        with conn.cursor() as cursor:
            sql = "SELECT fcm_token FROM users WHERE user_UUID = %s"
            cursor.execute(sql, (user_uuid,))
            row = cursor.fetchone()

        # 3) Dacă nu găsește user
        if row is None or not row.get("fcm_token"):
            return {
                "statusCode": 404,
                "headers": { "Content-Type": "application/json" },
                "body": { "error": "User not found" }
            }

        # 4) Răspuns de succes
        return {
            "statusCode": 200,
            "headers": { "Content-Type": "application/json" },
            "body": { "fcm_token": row["fcm_token"] }
        }

    except Exception as e:
        print(f"Internal error: {e}")
        return {
            "statusCode": 500,
            "headers": { "Content-Type": "application/json" },
            "body": { "error": "Internal server error" }
        }
    finally:
        conn.close()
