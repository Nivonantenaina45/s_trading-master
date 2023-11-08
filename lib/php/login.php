<?php
include "connection.php";
$email = $_POST['email'];
$pass = $_POST['password'];

$response = [];

try {
    if (isset($email, $pass)) {
        $req = $db->prepare("SELECT * FROM agent WHERE email=? AND password=?");
        $req->execute(array($email,$pass));
        $exist = $req->rowCount();
        if ($exist == 1) {
            $row = $req->fetch();
            $response["success"] = 1;
            $response["message"] = "Connexion réussie";
            $response["nom"] = $row['nom'];
            $response["prenom"] = $row['prenom'];
        } else {
            $response["success"] = 0;
            $response["message"] = "L'email ou le mot de passe est incorrect";
        }
    } else {
        $response["success"] = 0;
        $response["message"] = "Erreur, données vides";
    }
} catch (\Throwable $th) {
    $response["success"] = 0;
    $response["message"] = "Erreur: " . $th->getMessage();
}

echo json_encode(["data" => $response]);
?>
