<?php
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$db_name = "wrestling_app";
$username = "root";
$password = "";

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Check if competition_UUID is provided
    if (!isset($_GET['competition_UUID'])) {
        echo json_encode(["error" => "competition_UUID is required"]);
        exit;
    }

    $competitionUUID = $_GET['competition_UUID'];

    // Query to get distinct weight categories along with wrestling styles
    $stmt = $conn->prepare("
        SELECT DISTINCT w.wrestling_style, ci.weight_category
        FROM competitions_invitations ci
        JOIN wrestlers w ON ci.recipient_UUID = w.wrestler_UUID
        WHERE ci.competition_UUID = :competitionUUID
        AND ci.recipient_role = 'Wrestler'
        AND ci.weight_category IS NOT NULL
        ORDER BY w.wrestling_style, CAST(ci.weight_category AS UNSIGNED) ASC
    ");

    // Bind parameter
    $stmt->bindParam(':competitionUUID', $competitionUUID, PDO::PARAM_INT);
    $stmt->execute();

    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($result)) {
        echo json_encode($result);
    } else {
        echo json_encode(["message" => "No weight categories found for this competition"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
