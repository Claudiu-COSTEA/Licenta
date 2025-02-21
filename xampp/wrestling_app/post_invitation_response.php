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
    if (!isset($data['competition_UUID']) || !isset($data['recipient_UUID']) || !isset($data['recipient_role']) || !isset($data['invitation_status'])) {
        echo json_encode(["error" => "Missing required fields"]);
        exit;
    }

    // Extract data
    $competitionUUID = $data['competition_UUID'];
    $recipientUUID = $data['recipient_UUID'];
    $recipientRole = $data['recipient_role'];
    $invitationStatus = $data['invitation_status'];
    $invitationResponseDate = date('Y-m-d H:i:s'); // Current timestamp

    // Update the invitation status & response date ONLY if current status is "Pending"
    $stmt = $conn->prepare("
        UPDATE competitions_invitations 
        SET invitation_status = :invitationStatus, invitation_response_date = :invitationResponseDate
        WHERE competition_UUID = :competitionUUID 
        AND recipient_UUID = :recipientUUID 
        AND recipient_role = :recipientRole 
        AND invitation_status = 'Pending'
    ");

    // Bind parameters
    $stmt->bindParam(':competitionUUID', $competitionUUID, PDO::PARAM_INT);
    $stmt->bindParam(':recipientUUID', $recipientUUID, PDO::PARAM_INT);
    $stmt->bindParam(':recipientRole', $recipientRole, PDO::PARAM_STR);
    $stmt->bindParam(':invitationStatus', $invitationStatus, PDO::PARAM_STR);
    $stmt->bindParam(':invitationResponseDate', $invitationResponseDate, PDO::PARAM_STR);

    // Execute query
    if ($stmt->execute()) {
        // Check if any row was updated
        if ($stmt->rowCount() > 0) {
            echo json_encode(["success" => "Invitation updated successfully"]);
        } else {
            echo json_encode(["error" => "Invitation status is not 'Pending' or no changes made"]);
        }
    } else {
        echo json_encode(["error" => "Failed to update invitation"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
