<?php
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$db_name = "wrestling_app";
$username = "root";
$password = "";

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Check if coach_UUID and competition_UUID are provided
    if (!isset($_GET['coach_UUID']) || !isset($_GET['competition_UUID'])) {
        echo json_encode(["error" => "coach_UUID and competition_UUID are required"]);
        exit;
    }

    $coachUUID = $_GET['coach_UUID'];
    $competitionUUID = $_GET['competition_UUID'];

    $stmt = $conn->prepare("
        SELECT 
            w.wrestler_UUID,
            u.user_full_name AS wrestler_name,
            w.wrestling_style,
            ci.invitation_status
        FROM wrestlers w
        JOIN users u ON w.wrestler_UUID = u.user_UUID
        LEFT JOIN competitions_invitations ci 
            ON w.wrestler_UUID = ci.recipient_UUID 
            AND ci.competition_UUID = :competitionUUID
            AND ci.recipient_role = 'Wrestler'
        WHERE w.coach_UUID = :coachUUID
    ");

    $stmt->bindParam(':coachUUID', $coachUUID, PDO::PARAM_INT);
    $stmt->bindParam(':competitionUUID', $competitionUUID, PDO::PARAM_INT);
    $stmt->execute();

    $wrestlers = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($wrestlers)) {
        echo json_encode($wrestlers);
    } else {
        echo json_encode(["message" => "No wrestlers found for this coach in the given competition"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
