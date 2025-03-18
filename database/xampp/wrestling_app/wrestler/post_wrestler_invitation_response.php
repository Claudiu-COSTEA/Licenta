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
        !isset($data['invitation_status']) || !isset($data['weight_category'])) {
        echo json_encode(["error" => "Missing required fields"]);
        exit;
    }

    // Extract data from request
    $competitionUUID = $data['competition_UUID'];
    $recipientUUID = $data['recipient_UUID'];
    $newInvitationStatus = $data['invitation_status'];
    $newWeightCategory = $data['weight_category'];
    $invitationResponseDate = date('Y-m-d H:i:s'); // Current timestamp

    // Check if the invitation is in "Pending" status
    $checkStmt = $conn->prepare("
        SELECT invitation_status FROM competitions_invitations 
        WHERE competition_UUID = :competitionUUID AND recipient_UUID = :recipientUUID AND recipient_role = 'Wrestler'
    ");
    $checkStmt->bindParam(':competitionUUID', $competitionUUID, PDO::PARAM_INT);
    $checkStmt->bindParam(':recipientUUID', $recipientUUID, PDO::PARAM_INT);
    $checkStmt->execute();
    $currentInvitation = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$currentInvitation) {
        echo json_encode(["error" => "Invitation not found"]);
        exit;
    }

    if ($currentInvitation['invitation_status'] !== "Pending") {
        echo json_encode(["error" => "Invitation status is not 'Pending' and cannot be updated"]);
        exit;
    }

    // Update the invitation status and weight category
    $updateStmt = $conn->prepare("
        UPDATE competitions_invitations 
        SET invitation_status = :newInvitationStatus, 
            weight_category = :newWeightCategory, 
            invitation_response_date = :invitationResponseDate
        WHERE competition_UUID = :competitionUUID AND recipient_UUID = :recipientUUID AND recipient_role = 'Wrestler'
    ");

    $updateStmt->bindParam(':newInvitationStatus', $newInvitationStatus, PDO::PARAM_STR);
    $updateStmt->bindParam(':newWeightCategory', $newWeightCategory, PDO::PARAM_STR);
    $updateStmt->bindParam(':invitationResponseDate', $invitationResponseDate, PDO::PARAM_STR);
    $updateStmt->bindParam(':competitionUUID', $competitionUUID, PDO::PARAM_INT);
    $updateStmt->bindParam(':recipientUUID', $recipientUUID, PDO::PARAM_INT);

    if ($updateStmt->execute()) {
        echo json_encode(["success" => "Invitation updated successfully"]);
    } else {
        echo json_encode(["error" => "Failed to update invitation"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
