<?php
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$db_name = "wrestling_app";
$username = "root";
$password = "";

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Get JSON input
    $data = json_decode(file_get_contents("php://input"), true);

    // Debugging: Print the received data
    file_put_contents("debug_log.txt", json_encode($data, JSON_PRETTY_PRINT), FILE_APPEND);

    // Check required fields
    if (!isset($data['competition_name']) || !isset($data['competition_start_date']) || !isset($data['competition_end_date']) || !isset($data['competition_location'])) {
        echo json_encode(["error" => "Missing required fields", "received_data" => $data]);
        exit;
    }

    // Prepare and execute SQL query
    $stmt = $conn->prepare("
        INSERT INTO competitions (competition_name, competition_start_date, competition_end_date, competition_location) 
        VALUES (:competition_name, :competition_start_date, :competition_end_date, :competition_location)
    ");

    $stmt->bindParam(':competition_name', $data['competition_name'], PDO::PARAM_STR);
    $stmt->bindParam(':competition_start_date', $data['competition_start_date'], PDO::PARAM_STR);
    $stmt->bindParam(':competition_end_date', $data['competition_end_date'], PDO::PARAM_STR);
    $stmt->bindParam(':competition_location', $data['competition_location'], PDO::PARAM_STR);

    if ($stmt->execute()) {
        echo json_encode(["success" => "Competition added successfully"]);
    } else {
        echo json_encode(["error" => "Failed to add competition"]);
    }

} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
