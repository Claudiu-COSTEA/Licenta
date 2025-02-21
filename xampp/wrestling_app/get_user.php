<?php
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$db_name = "wrestling_app";
$username = "root";
$password = "";

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if (isset($_GET['email'])) {
        $email = $_GET['email'];

        $stmt = $conn->prepare("SELECT * FROM users WHERE user_email = :email");
        $stmt->bindParam(':email', $email, PDO::PARAM_STR);
        $stmt->execute();

        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user) {
            echo json_encode($user);
        } else {
            echo json_encode(["message" => "User not found"]);
        }
    } else {
        echo json_encode(["error" => "email is required"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
