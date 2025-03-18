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

    // Check required fields
    if (!isset($data['user_UUID']) || !isset($data['fcm_token'])) {
        echo json_encode(["error" => "Missing required fields"]);
        exit;
    }

    // Extract data
    $userUUID = $data['user_UUID'];
    $fcmToken = $data['fcm_token'];

    // Update FCM Token for the user
    $stmt = $conn->prepare("
        UPDATE users SET fcm_token = :fcmToken WHERE user_UUID = :userUUID
    ");
    $stmt->bindParam(':fcmToken', $fcmToken, PDO::PARAM_STR);
    $stmt->bindParam(':userUUID', $userUUID, PDO::PARAM_INT);

    if ($stmt->execute()) {
        echo json_encode(["success" => "FCM token updated successfully"]);
    } else {
        echo json_encode(["error" => "Failed to update FCM token"]);
    }

} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
