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
    """AWS Lambda function to insert a new competition into the database."""

    #Check if "body" exists in event
    if "body" not in event or event["body"] is None:
        return {
            "statusCode": 400,
            "body": {"error": "Request body is required"}
        }

    body = event["body"]

    # Extract competition details from request body
    competition_name = body.get("competition_name")
    competition_start_date = body.get("competition_start_date")
    competition_end_date = body.get("competition_end_date")
    competition_location = body.get("competition_location")

    # Validate required fields
    if not all([competition_name, competition_start_date, competition_end_date]):
        return {
            "statusCode": 400,
            "body": {"error": "competition_name, competition_start_date, and competition_end_date are required"}
        }

    # Connect to the database
    connection = connect_to_db()
    if not connection:
        return {
            "statusCode": 500,
            "body": {"error": "Database connection failed"}
        }

    try:
        with connection.cursor() as cursor:
            sql_query = """
                INSERT INTO competitions (
                    competition_name, 
                    competition_start_date, 
                    competition_end_date, 
                    competition_location
                ) VALUES (%s, %s, %s, %s)
            """
            cursor.execute(sql_query, (competition_name, competition_start_date, competition_end_date, competition_location))
            connection.commit()
        
        return {
            "statusCode": 201,
            "body": {"message": "Competition added successfully"}
        }
    
    except Exception as e:
        return {
            "statusCode": 500,
            "body": {"error": str(e)}
        }
    
    finally:
        connection.close()
