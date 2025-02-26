<?php
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$db_name = "wrestling_app";
$username = "root";
$password = "";

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Retrieve JSON input
    $data = json_decode(file_get_contents("php://input"), true);

    // Validate required fields
    if (!isset($data['competition_UUID'], $data['recipient_UUID'], $data['recipient_role'], $data['invitation_status'], $data['invitation_deadline'])) {
        echo json_encode(["error" => "Missing required fields"]);
        exit;
    }

    $competitionUUID = $data['competition_UUID'];
    $recipientUUID = $data['recipient_UUID'];
    $recipientRole = $data['recipient_role'];
    $weightCategory = $data['weight_category'] ?? NULL; // Optional for non-wrestlers
    $invitationStatus = $data['invitation_status'];
    $invitationDate = date('Y-m-d H:i:s'); // Current timestamp
    $invitationDeadline = $data['invitation_deadline'];
    $refereeVerification = $data['referee_verification'] ?? NULL;

    // Prepare SQL query
    $stmt = $conn->prepare("
        INSERT INTO competitions_invitations 
        (competition_UUID, recipient_UUID, recipient_role, weight_category, invitation_status, invitation_date, invitation_deadline, referee_verification) 
        VALUES 
        (:competitionUUID, :recipientUUID, :recipientRole, :weightCategory, :invitationStatus, :invitationDate, :invitationDeadline, :refereeVerification)
    ");

    // Bind parameters
    $stmt->bindParam(':competitionUUID', $competitionUUID, PDO::PARAM_INT);
    $stmt->bindParam(':recipientUUID', $recipientUUID, PDO::PARAM_INT);
    $stmt->bindParam(':recipientRole', $recipientRole, PDO::PARAM_STR);
    $stmt->bindParam(':weightCategory', $weightCategory, PDO::PARAM_STR);
    $stmt->bindParam(':invitationStatus', $invitationStatus, PDO::PARAM_STR);
    $stmt->bindParam(':invitationDate', $invitationDate, PDO::PARAM_STR);
    $stmt->bindParam(':invitationDeadline', $invitationDeadline, PDO::PARAM_STR);
    $stmt->bindParam(':refereeVerification', $refereeVerification, PDO::PARAM_STR);

    // Execute the statement
    if ($stmt->execute()) {
        echo json_encode(["success" => "Invitation added successfully"]);
    } else {
        echo json_encode(["error" => "Failed to add invitation"]);
    }

} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
