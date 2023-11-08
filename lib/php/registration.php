<?php
include "connection.php";

$nom = $_POST['nom'];
$prenom = $_POST['prénom'];
$email = $_POST['email'];
$pass = $_POST['password'];

try {
    if (isset($nom, $prenom, $email, $pass)) {
        $req = $db->prepare("SELECT * FROM agent WHERE email=?");
        $req->execute(array($email));
        $exist = $req->rowCount();

        if ($exist == 0) {
            $req = $db->prepare("INSERT INTO agent (nom, prenom, email, password) VALUES (?, ?, ?, ?)");
            $inserted = $req->execute(array($nom, $prenom, $email, $pass));

            if ($inserted) {
                echo json_encode([
                    "success" => true,
                    "message" => "Enregistrement réussi"
                ]);
            } else {
                echo json_encode([
                    "success" => false,
                    "message" => "Erreur d'enregistrement"
                ]);
            }
        } else {
            echo json_encode([
                "success" => false,
                "message" => "L'email existe déjà"
            ]);
        }
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Données manquantes"
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Erreur de base de données: " . $e->getMessage()
    ]);
}
