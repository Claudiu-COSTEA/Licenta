import pymysql

# Database connection details
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASSWORD = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def connect_to_db():
    """Establish a connection to the MySQL database."""
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
        return connection
    except Exception as e:
        print("Connection error:", e)
        return None

def lambda_handler(event, context):
    # Extract query string parameter
    competition_uuid = event["competition_UUID"]

    if not competition_uuid:
        return {
            "statusCode": 400,
            "body": {"error": "competition_UUID is required"}
        }

    conn = connect_to_db()
    if conn is None:
        return {
            "statusCode": 500,
            "body": {"error": "Database connection failed"}
        }

    try:
        with conn.cursor() as cursor:
            query = """
                SELECT DISTINCT w.wrestling_style, ci.weight_category
                FROM competitions_invitations ci
                JOIN wrestlers w ON ci.recipient_UUID = w.wrestler_UUID
                WHERE ci.competition_UUID = %s
                AND ci.recipient_role = 'Wrestler'
                AND ci.weight_category IS NOT NULL
                ORDER BY w.wrestling_style, CAST(ci.weight_category AS UNSIGNED) ASC
            """
            cursor.execute(query, (competition_uuid,))
            result = cursor.fetchall()

        if result:
            return {
                "statusCode": 200,
                "body": result
            }
        else:
            return {
                "statusCode": 200,
                "body": {"message": "No weight categories found for this competition"}
            }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }
    finally:
        conn.close()
