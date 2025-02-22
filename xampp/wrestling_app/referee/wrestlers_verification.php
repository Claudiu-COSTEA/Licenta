<?php
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$db_name = "wrestling_app";
$username = "root";
$password = "";

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Check if required parameters are provided
    if (!isset($_GET['wrestling_style']) || !isset($_GET['weight_category']) || !isset($_GET['competition_UUID'])) {
        echo json_encode(["error" => "wrestling_style, weight_category, and competition_UUID are required"]);
        exit;
    }

    $wrestlingStyle = $_GET['wrestling_style'];
    $weightCategory = $_GET['weight_category'];
    $competitionUUID = $_GET['competition_UUID'];

    // SQL Query to fetch wrestlers with their coach, wrestling club, competition details, and only those with 'Accepted' invitations
    $stmt = $conn->prepare("
        SELECT 
            w.wrestler_UUID,
            wu.user_full_name AS wrestler_name,
            w.wrestling_style,
            ci.weight_category,
            c.coach_UUID,
            cu.user_full_name AS coach_name,
            wc.wrestling_club_UUID,
            wu_club.user_full_name AS wrestling_club_name,
            comp.competition_UUID,
            comp.competition_name,
            ci.invitation_status,
            ci.referee_verification
        FROM wrestlers w
        JOIN users wu ON w.wrestler_UUID = wu.user_UUID
        JOIN coaches c ON w.coach_UUID = c.coach_UUID
        JOIN users cu ON c.coach_UUID = cu.user_UUID
        JOIN wrestling_club wc ON c.wrestling_club_UUID = wc.wrestling_club_UUID
        JOIN users wu_club ON wc.wrestling_club_UUID = wu_club.user_UUID
        JOIN competitions_invitations ci ON w.wrestler_UUID = ci.recipient_UUID 
            AND ci.recipient_role = 'Wrestler'
            AND ci.competition_UUID = :competitionUUID
            AND ci.invitation_status = 'Accepted'
        JOIN competitions comp ON ci.competition_UUID = comp.competition_UUID
        WHERE w.wrestling_style = :wrestlingStyle
        AND ci.weight_category = :weightCategory
    ");

    // Bind parameters
    $stmt->bindParam(':wrestlingStyle', $wrestlingStyle, PDO::PARAM_STR);
    $stmt->bindParam(':weightCategory', $weightCategory, PDO::PARAM_STR);
    $stmt->bindParam(':competitionUUID', $competitionUUID, PDO::PARAM_INT);

    $stmt->execute();

    $wrestlers = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($wrestlers)) {
        echo json_encode($wrestlers);
    } else {
        echo json_encode(["message" => "No wrestlers found for the given criteria"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
