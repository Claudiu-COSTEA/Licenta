import mysql.connector
import random

# Database Configuration
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "wrestling_app"
}

def get_accepted_wrestlers(competition_uuid, wrestling_style, weight_category):
    """Fetch all accepted wrestlers for a given competition, wrestling style, and weight category."""
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)

    query = """
        SELECT recipient_UUID FROM competitions_invitations
        WHERE competition_UUID = %s
        AND wrestling_style = %s
        AND weight_category = %s
        AND invitation_status = 'Accepted'
    """

    cursor.execute(query, (competition_uuid, wrestling_style, weight_category))
    wrestlers = [row["recipient_UUID"] for row in cursor.fetchall()]

    cursor.close()
    conn.close()
    return wrestlers

def generate_first_round(wrestlers):
    """Ensure we have 2^p wrestlers after the first round."""
    random.shuffle(wrestlers)
    num_wrestlers = len(wrestlers)
    
    # Find the nearest power of 2
    next_power_of_2 = 2 ** ((num_wrestlers - 1).bit_length())
    extra_fights_needed = num_wrestlers - (next_power_of_2 // 2)
    
    pairs = []
    remaining_wrestlers = wrestlers[:]
    
    # Generate extra fights
    if extra_fights_needed > 0:
        extra_fights = wrestlers[:2 * extra_fights_needed]
        remaining_wrestlers = wrestlers[2 * extra_fights_needed:]
        
        for i in range(0, len(extra_fights), 2):
            pairs.append((extra_fights[i], extra_fights[i+1]))

        # Winners of extra fights move to next round
        remaining_wrestlers += [random.choice(pair) for pair in pairs]

    # Generate the rest of the first round
    first_round_pairs = [(remaining_wrestlers[i], remaining_wrestlers[i+1]) for i in range(0, len(remaining_wrestlers), 2)]

    return pairs + first_round_pairs, remaining_wrestlers

def insert_fights(competition_uuid, competition_round, wrestling_style, weight_category, pairs):
    """Insert fights into the database."""
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    for i, (red, blue) in enumerate(pairs):
        query = """
            INSERT INTO competition_fights (
                competition_UUID, competition_round, competition_fight_order_number,
                wrestling_style, competition_fight_weight_category,
                referee_UUID_1, referee_UUID_2, referee_UUID_3,
                wrestling_club_UUID_red, wrestling_club_UUID_blue,
                coach_UUID_red, coach_UUID_blue,
                wrestler_UUID_red, wrestler_UUID_blue
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (competition_uuid, competition_round, i + 1, wrestling_style, weight_category, 
                               1, 2, 3, 1, 2, 1, 2, red, blue))

    conn.commit()
    cursor.close()
    conn.close()

def determine_next_round_name(current_round):
    """Get the next round name in the tournament structure."""
    rounds_order = ["Round 32", "Round 16", "Round 8", "Round 4", "Round 2", "Final"]
    try:
        return rounds_order[rounds_order.index(current_round) + 1]
    except IndexError:
        return None  # No next round

def generate_tournament(competition_uuid, wrestling_style, weight_category):
    """Main function to generate fights for an entire tournament."""
    wrestlers = get_accepted_wrestlers(competition_uuid, wrestling_style, weight_category)

    if len(wrestlers) < 2:
        print("⚠️ Not enough wrestlers to start a competition!")
        return

    print(f"🎯 Generating fights for Competition {competition_uuid}, Style {wrestling_style}, Category {weight_category}...")

    # First round handling (extra matches if needed)
    first_round_pairs, remaining_wrestlers = generate_first_round(wrestlers)
    insert_fights(competition_uuid, "Round 16", wrestling_style, weight_category, first_round_pairs)

    # Continue tournament rounds
    current_round = "Round 16"
    while len(remaining_wrestlers) > 1:
        next_round = determine_next_round_name(current_round)
        if not next_round:
            break  # Tournament complete

        fight_pairs = [(remaining_wrestlers[i], remaining_wrestlers[i+1]) for i in range(0, len(remaining_wrestlers), 2)]
        insert_fights(competition_uuid, next_round, wrestling_style, weight_category, fight_pairs)

        remaining_wrestlers = [random.choice(pair) for pair in fight_pairs]  # Winners advance
        current_round = next_round

    print(f"✅ Fights generated and stored in the database!")

# Example: Generate fights for competition 1, Greco Roman style, 77 kg category
generate_tournament(1, "Greco Roman", "77")
