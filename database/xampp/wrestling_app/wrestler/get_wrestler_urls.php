<?php
header("Content-Type: application/json; charset=UTF-8");

// Database connection
$host = "localhost"; 
$db_name = "wrestling_app"; 
$username = "root"; 
$password = ""; 

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Check if wrestler_UUID is provided
    if (!isset($_GET['wrestler_UUID'])) {
        echo json_encode(["error" => "wrestler_UUID is required"]);
        exit;
    }

    $wrestlerUUID = $_GET['wrestler_UUID'];

    // Fetch medical and license documents
    $stmt = $conn->prepare("SELECT medical_document, license_document FROM wrestlers WHERE wrestler_UUID = :wrestlerUUID");
    $stmt->bindParam(':wrestlerUUID', $wrestlerUUID, PDO::PARAM_INT);
    $stmt->execute();

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo json_encode([
            "wrestler_UUID" => $wrestlerUUID,
            "medical_document" => $result["medical_document"],
            "license_document" => $result["license_document"]
        ]);
    } else {
        echo json_encode(["error" => "No records found for this wrestler"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => "Database error: " . $e->getMessage()]);
}
?>
