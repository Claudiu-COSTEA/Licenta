SELECT DISTINCT
       w.wrestler_UUID,
       w.coach_UUID,
       c.wrestling_club_UUID
FROM competitions_invitations  AS ci
JOIN wrestlers        AS w  ON w.wrestler_UUID  = ci.recipient_UUID
JOIN coaches          AS c  ON c.coach_UUID     = w.coach_UUID
WHERE ci.recipient_role          = 'Wrestler'
  AND ci.referee_verification    = 'Confirmed'
  AND ci.invitation_response_date IS NOT NULL
  AND ci.competition_UUID        = 1          -- competiția vizată
  AND ci.weight_category         = '77'       -- categoria de greutate
  AND w.wrestling_style          = 'Greco Roman';


--=======================================================================================================

SELECT
    r.referee_UUID
FROM competitions_invitations  AS ci
JOIN referees   AS r  ON r.referee_UUID = ci.recipient_UUID
JOIN users      AS u  ON u.user_UUID    = r.referee_UUID
WHERE ci.competition_UUID = 1            -- ex.: 1
  AND ci.invitation_status = 'Confirmed' -- invitația acceptată
  AND ci.recipient_role    = 'Referee'
  AND r.wrestling_style    = 'Greco Roman';           -- ex.: '

--===============================================================================================

SELECT
    cu.user_full_name  AS coach_name,
    clu.user_full_name AS club_name
FROM wrestlers          AS w
JOIN coaches            AS c   ON c.coach_UUID           = w.coach_UUID
JOIN users              AS cu  ON cu.user_UUID           = c.coach_UUID          -- numele antrenorului
JOIN wrestling_club     AS cl  ON cl.wrestling_club_UUID = c.wrestling_club_UUID
JOIN users              AS clu ON clu.user_UUID          = cl.wrestling_club_UUID -- numele clubului
WHERE w.wrestler_UUID = 1;

--=======================================================================================================

SELECT
    r.referee_UUID
FROM competitions_invitations  AS ci
JOIN referees   AS r  ON r.referee_UUID = ci.recipient_UUID
JOIN users      AS u  ON u.user_UUID    = r.referee_UUID
WHERE ci.competition_UUID = 1            -- ex.: 1
  AND ci.invitation_status = 'Confirmed' -- invitația acceptată
  AND ci.recipient_role    = 'Referee'
  AND r.wrestling_style    = 'Greco Roman';           -- ex.: '
