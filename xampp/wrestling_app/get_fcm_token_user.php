<?php
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$db_name = "wrestling_app";
$username = "root";
$password = "";

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Check if user_UUID is provided
    if (!isset($_GET['user_UUID'])) {
        echo json_encode(["error" => "user_UUID is required"]);
        exit;
    }

    $userUUID = $_GET['user_UUID'];

    // Fetch the FCM token from the database
    $stmt = $conn->prepare("SELECT fcm_token FROM users WHERE user_UUID = :userUUID");
    $stmt->bindParam(':userUUID', $userUUID, PDO::PARAM_INT);
    $stmt->execute();

    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user && !empty($user['fcm_token'])) {
        echo json_encode(["fcm_token" => $user['fcm_token']]);
    } else {
        echo json_encode(["error" => "FCM token not found"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
