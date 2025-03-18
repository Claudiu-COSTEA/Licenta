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
    if (!isset($data['competition_UUID']) || !isset($data['recipient_UUID']) || 
        !isset($data['recipient_role']) || !isset($data['referee_verification'])) {
        echo json_encode(["error" => "Missing required fields"]);
        exit;
    }

    // Extract data from request
    $competitionUUID = $data['competition_UUID'];
    $recipientUUID = $data['recipient_UUID'];
    $recipientRole = $data['recipient_role'];
    $refereeVerification = $data['referee_verification'];

    // Ensure the referee verification value is valid
    $allowedStatuses = ['Confirmed', 'Declined'];
    if (!in_array($refereeVerification, $allowedStatuses)) {
        echo json_encode(["error" => "Invalid referee_verification value"]);
        exit;
    }

    // Check if the invitation exists and is valid
    $checkStmt = $conn->prepare("
        SELECT * FROM competitions_invitations 
        WHERE competition_UUID = :competitionUUID 
        AND recipient_UUID = :recipientUUID 
        AND recipient_role = :recipientRole
    ");
    $checkStmt->bindParam(':competitionUUID', $competitionUUID, PDO::PARAM_INT);
    $checkStmt->bindParam(':recipientUUID', $recipientUUID, PDO::PARAM_INT);
    $checkStmt->bindParam(':recipientRole', $recipientRole, PDO::PARAM_STR);
    $checkStmt->execute();

    if ($checkStmt->rowCount() === 0) {
        echo json_encode(["error" => "Invitation not found"]);
        exit;
    }

    // Update referee_verification field
    $updateStmt = $conn->prepare("
        UPDATE competitions_invitations 
        SET referee_verification = :refereeVerification 
        WHERE competition_UUID = :competitionUUID 
        AND recipient_UUID = :recipientUUID 
        AND recipient_role = :recipientRole
    ");
    $updateStmt->bindParam(':refereeVerification', $refereeVerification, PDO::PARAM_STR);
    $updateStmt->bindParam(':competitionUUID', $competitionUUID, PDO::PARAM_INT);
    $updateStmt->bindParam(':recipientUUID', $recipientUUID, PDO::PARAM_INT);
    $updateStmt->bindParam(':recipientRole', $recipientRole, PDO::PARAM_STR);

    // Execute update
    if ($updateStmt->execute()) {
        echo json_encode(["success" => "Referee verification updated successfully"]);
    } else {
        echo json_encode(["error" => "Failed to update referee verification"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
