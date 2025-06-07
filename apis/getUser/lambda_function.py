import json
import pymysql

# Database connection details
DB_HOST = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASSWORD = "admin123"
DB_NAME = "wrestlingMobileAppDatabase"

def connect_to_db():
    """Establish connection to the RDS MySQL database."""
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
        print(f"Error connecting to database: {str(e)}")
        return None

def lambda_handler(event, context):
    """AWS Lambda function to fetch user data plus wrestling_style (or 'All' for clubs)."""

    email = event.get("email")
    if not email:
        return {
            "statusCode": 400,
            "body": {"error": "Email parameter is required"}
        }

    conn = connect_to_db()
    if not conn:
        return {
            "statusCode": 500,
            "body": {"error": "Database connection failed"}
        }

    try:
        with conn.cursor() as cursor:
            # 1) Fetch basic user info
            sql_user = """
                SELECT user_UUID, user_email, user_full_name, user_type, fcm_token
                FROM users
                WHERE user_email = %s;
            """
            cursor.execute(sql_user, (email,))
            user = cursor.fetchone()

            if not user:
                return {
                    "statusCode": 404,
                    "body": {"error": "User not found"}
                }

            # 2) Determine wrestling_style
            utype = user["user_type"]
            uid   = user["user_UUID"]
            style = None

            if utype == "Wrestler":
                cursor.execute(
                    "SELECT wrestling_style FROM wrestlers WHERE wrestler_UUID = %s;",
                    (uid,)
                )
                row = cursor.fetchone()
                style = row["wrestling_style"] if row else None

            elif utype == "Coach":
                cursor.execute(
                    "SELECT wrestling_style FROM coaches WHERE coach_UUID = %s;",
                    (uid,)
                )
                row = cursor.fetchone()
                style = row["wrestling_style"] if row else None

            elif utype == "Referee":
                cursor.execute(
                    "SELECT wrestling_style FROM referees WHERE referee_UUID = %s;",
                    (uid,)
                )
                row = cursor.fetchone()
                style = row["wrestling_style"] if row else None

            elif utype == "Wrestling club":
                # Clubs have no specific style—return "All"
                style = "All"

            # Admins and other roles: style stays None

            user["wrestling_style"] = style

            return {
                "statusCode": 200,
                "body": user
            }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }

    finally:
        conn.close()
