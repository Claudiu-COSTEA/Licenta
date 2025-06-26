# lambda_function.py – Returnează toți antrenorii împreună cu numele clubului lor de lupte

import json
import pymysql

# ─── CONFIG RDS ─────────────────────────────────────────────
DB_HOST     = "database.csvci28ie14d.us-east-1.rds.amazonaws.com"
DB_USER     = "admin"
DB_PASSWORD = "admin123"
DB_NAME     = "wrestlingMobileAppDatabase"

def get_db_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        autocommit=True,
        cursorclass=pymysql.cursors.DictCursor
    )

def lambda_handler(event, context):
    """
    Această funcție returnează lista tuturor antrenorilor cu:
      • coach_UUID
      • coach_name      (user_full_name din tabela users)
      • wrestling_style (din tabela coaches)
      • club_UUID       (UUID-ul clubului asociat)
      • club_name       (user_full_name al clubului din tabela users)
      • club_city       (orașul clubului din tabela wrestling_club)
    """

    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            sql = """
                SELECT 
                    c.coach_UUID,
                    u_coach.user_full_name   AS coach_name,
                    c.wrestling_style,
                    wc.wrestling_club_UUID   AS club_UUID,
                    u_club.user_full_name    AS club_name,
                    wc.wrestling_club_city   AS club_city
                FROM coaches AS c
                JOIN users AS u_coach
                  ON c.coach_UUID = u_coach.user_UUID
                JOIN wrestling_club AS wc
                  ON c.wrestling_club_UUID = wc.wrestling_club_UUID
                JOIN users AS u_club
                  ON wc.wrestling_club_UUID = u_club.user_UUID
                ;
            """
            cur.execute(sql)
            coaches = cur.fetchall()

    except Exception as e:
        # Dacă apare vreo eroare la interogare sau conectare
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "error": f"Eroare la interogarea bazei de date: {e}"
            })
        }
    finally:
        try:
            conn.close()
        except:
            pass

    # Returnează lista de antrenori în format JSON
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(coaches, default=str)
    }
