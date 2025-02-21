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
    if (!isset($data['competition_UUID']) || !isset($data['recipient_UUID']) || !isset($data['invitation_deadline']) || !isset($data['weight_category'])) {
        echo json_encode(["error" => "Missing required fields"]);
        exit;
    }

    // Extract data from request
    $competitionUUID = $data['competition_UUID'];
    $recipientUUID = $data['recipient_UUID'];
    $invitationDeadline = $data['invitation_deadline'];
    $weightCategory = $data['weight_category'];
    $invitationDate = date('Y-m-d H:i:s'); // Current timestamp
    $invitationStatus = "Pending"; // Default status
    $recipientRole = "Wrestler"; // Since we're inviting a wrestler

    // Insert invitation into database with weight_category
    $stmt = $conn->prepare("
        INSERT INTO competitions_invitations (
            competition_UUID, recipient_UUID, recipient_role, 
            invitation_status, invitation_date, invitation_deadline, weight_category
        ) VALUES (
            :competitionUUID, :recipientUUID, :recipientRole, 
            :invitationStatus, :invitationDate, :invitationDeadline, :weightCategory
        )
    ");

    // Bind parameters
    $stmt->bindParam(':competitionUUID', $competitionUUID, PDO::PARAM_INT);
    $stmt->bindParam(':recipientUUID', $recipientUUID, PDO::PARAM_INT);
    $stmt->bindParam(':recipientRole', $recipientRole, PDO::PARAM_STR);
    $stmt->bindParam(':invitationStatus', $invitationStatus, PDO::PARAM_STR);
    $stmt->bindParam(':invitationDate', $invitationDate, PDO::PARAM_STR);
    $stmt->bindParam(':invitationDeadline', $invitationDeadline, PDO::PARAM_STR);
    $stmt->bindParam(':weightCategory', $weightCategory, PDO::PARAM_STR);

    // Execute query
    if ($stmt->execute()) {
        echo json_encode(["success" => "Invitation sent successfully to wrestler"]);
    } else {
        echo json_encode(["error" => "Failed to send invitation"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
