<?php
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$db_name = "wrestling_app";
$username = "root";
$password = "";

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Check if wrestling_club_UUID and competition_UUID are provided
    if (!isset($_GET['wrestling_club_UUID']) || !isset($_GET['competition_UUID'])) {
        echo json_encode(["error" => "wrestling_club_UUID and competition_UUID are required"]);
        exit;
    }

    $wrestlingClubUUID = $_GET['wrestling_club_UUID'];
    $competitionUUID = $_GET['competition_UUID'];

    $stmt = $conn->prepare("
        SELECT 
            c.coach_UUID,
            u.user_full_name AS coach_name,
            c.wrestling_style,
            ci.invitation_status
        FROM coaches c
        JOIN users u ON c.coach_UUID = u.user_UUID
        LEFT JOIN competitions_invitations ci 
            ON c.coach_UUID = ci.recipient_UUID 
            AND ci.competition_UUID = :competitionUUID
            AND ci.recipient_role = 'Coach'
        WHERE c.wrestling_club_UUID = :wrestlingClubUUID
    ");

    $stmt->bindParam(':wrestlingClubUUID', $wrestlingClubUUID, PDO::PARAM_INT);
    $stmt->bindParam(':competitionUUID', $competitionUUID, PDO::PARAM_INT);
    $stmt->execute();

    $coaches = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($coaches)) {
        echo json_encode($coaches);
    } else {
        echo json_encode(["message" => "No coaches found for this wrestling club"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
