import functions_framework
import pymysql
import json
import os

# Function to connect to MySQL and fetch filtered wrestlers
def get_wrestlers_from_db(competition_id, weight_category, wrestling_style, round_number):
    connection = pymysql.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASS"),
        database=os.getenv("DB_NAME"),
        cursorclass=pymysql.cursors.DictCursor,
    )
    
    with connection.cursor() as cursor:
        query = """
        SELECT full_name, weight_category, wrestling_style 
        FROM wrestlers 
        WHERE competition_id = %s 
          AND weight_category = %s 
          AND wrestling_style = %s 
          AND round_number = %s
        """
        cursor.execute(query, (competition_id, weight_category, wrestling_style, round_number))
        wrestlers = cursor.fetchall()

    connection.close()
    return wrestlers


# Function to check if a number is a power of two
def is_power_of_two(n):
    return n > 0 and (n & (n - 1)) == 0


# Function to find the largest power of 2 ≤ n
def largest_power_of_two_less_than_or_equal_to(n):
    power = 1
    while power * 2 <= n:
        power *= 2
    return power


# Function to calculate how many extra wrestlers need to fight first
def difference_with_largest_power_of_two(n):
    return n - largest_power_of_two_less_than_or_equal_to(n)


# Function to generate matchups
def fights_generator(wrestlers):
    fights = []
    wrestlers_number = len(wrestlers)

    if is_power_of_two(wrestlers_number):
        for i in range(0, wrestlers_number, 2):
            fights.append({"wrestler_1": wrestlers[i], "wrestler_2": wrestlers[i + 1]})
    else:
        extra_fights = difference_with_largest_power_of_two(wrestlers_number)
        for i in range(0, extra_fights * 2, 2):
            fights.append({"wrestler_1": wrestlers[i], "wrestler_2": wrestlers[i + 1]})

    return fights


# Cloud Function HTTP Endpoint
@functions_framework.http
def generate_fights(request):
    """Google Cloud Function to generate fights based on filters."""
    
    # Parse query parameters from the request
    request_json = request.get_json(silent=True)
    
    competition_id = request_json.get("competition_id")
    weight_category = request_json.get("weight_category")
    wrestling_style = request_json.get("wrestling_style")
    round_number = request_json.get("round_number")

    # Validate inputs
    if not all([competition_id, weight_category, wrestling_style, round_number]):
        return json.dumps({"error": "Missing required parameters"}), 400, {"Content-Type": "application/json"}
    
    # Fetch wrestlers from database
    wrestlers = get_wrestlers_from_db(competition_id, weight_category, wrestling_style, round_number)

    # Generate matchups
    fights = fights_generator(wrestlers)

    # Response
    response = {
        "competition_id": competition_id,
        "weight_category": weight_category,
        "wrestling_style": wrestling_style,
        "round_number": round_number,
        "total_wrestlers": len(wrestlers),
        "matches": fights,
    }

    return json.dumps(response), 200, {"Content-Type": "application/json"}
