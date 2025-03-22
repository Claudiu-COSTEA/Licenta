import pymysql

# Database connection config
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASSWORD = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def connect_to_db():
    """Connect to MySQL RDS database."""
    try:
        return pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
    except Exception as e:
        print("Database connection failed:", e)
        return None

def lambda_handler(event, context):
    # Get query parameters
    wrestler_uuid = event["wrestler_UUID"]

    # Check if wrestler_UUID is provided
    if not wrestler_uuid:
        return {
            "statusCode": 400,
            "body": {"error": "wrestler_UUID is required"}
        }

    conn = connect_to_db()
    if not conn:
        return {
            "statusCode": 500,
            "body": {"error": "Database connection failed"}
        }

    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT medical_document, license_document
                FROM wrestlers
                WHERE wrestler_UUID = %s
            """
            cursor.execute(sql, (wrestler_uuid,))
            result = cursor.fetchone()

        if result:
            result["wrestler_UUID"] = wrestler_uuid
            return {
                "statusCode": 200,
                "body": result
            }
        else:
            return {
                "statusCode": 404,
                "body": {"error": "No records found for this wrestler"}
            }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": f"Database error: {str(e)}"}
        }

    finally:
        conn.close()
