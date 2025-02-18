<?php
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$db_name = "wrestling_app";
$username = "root";
$password = "";

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Check if wrestling_club_UUID is provided
    if (isset($_GET['wrestling_club_UUID'])) {
        $wrestlingClubUUID = $_GET['wrestling_club_UUID'];

        $stmt = $conn->prepare("
            SELECT 
                c.coach_UUID,
                u.user_full_name AS coach_name,
                c.wrestling_style
            FROM coaches c
            JOIN users u ON c.coach_UUID = u.user_UUID
            WHERE c.wrestling_club_UUID = :wrestlingClubUUID
        ");

        $stmt->bindParam(':wrestlingClubUUID', $wrestlingClubUUID, PDO::PARAM_INT);
        $stmt->execute();

        $coaches = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (!empty($coaches)) {
            echo json_encode($coaches);
        } else {
            echo json_encode(["message" => "No coaches found for this wrestling club"]);
        }
    } else {
        echo json_encode(["error" => "wrestling_club_UUID is required"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
