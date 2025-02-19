<?php
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$db_name = "wrestling_app";
$username = "root";
$password = "";

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if (isset($_GET['recipient_UUID'])) {
        $recipientUUID = $_GET['recipient_UUID'];

        $stmt = $conn->prepare("
            SELECT 
                ci.competition_invitation_UUID AS invitationUUID,
                ci.competition_UUID,
                ci.recipient_UUID,
                ci.recipient_role,
                ci.weight_category,
                c.competition_name,
                c.competition_start_date,
                c.competition_end_date,
                c.competition_location,
                ci.invitation_status,
                ci.invitation_date,
                ci.invitation_deadline,
                ci.invitation_response_date
            FROM competitions_invitations ci
            JOIN competitions c ON ci.competition_UUID = c.competition_UUID
            WHERE ci.recipient_UUID = :recipientUUID
        ");

        $stmt->bindParam(':recipientUUID', $recipientUUID, PDO::PARAM_INT);
        $stmt->execute();

        $invitations = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (!empty($invitations)) {
            echo json_encode($invitations);
        } else {
            echo json_encode(["message" => "No invitations found"]);
        }
    } else {
        echo json_encode(["error" => "recipient_UUID is required"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
