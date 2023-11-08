<?php
include "connection.php"; 

// Ajout d'un colis
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    $codeClient = $data['codeClient'];
    $tracking = $data['tracking'];
    $poids = $data['poids'];
    $volume = $data['volume'];
    $frais = $data['frais'];
    $modeEnvoie = $data['modeEnvoie'];
    $etat = $data['etat'];
    $facture = $data['facture'];

    $sql = "INSERT INTO colis (codeClient, tracking, poids, volume, frais, modeEnvoie, etat, facture) 
            VALUES ('$codeClient', '$tracking', $poids, $volume, $frais, '$modeEnvoie', '$etat', $facture)";

    if ($db->query($sql) === true) {
        $response = [
            "success" => 1,
            "message" => "Le colis a été ajouté avec succès"
        ];
    } else {
        $response = [
            "success" => 0,
            "message" => "Erreur: " . $db->error
        ];
    }

    echo json_encode(["data" => $response]);
}



?>
