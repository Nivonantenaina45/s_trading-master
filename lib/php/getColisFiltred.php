<?php
include "connection.php";

$response = [];

if (isset($_GET['tracking'])) {
    $tracking = $_GET['tracking'];

    try {
        $req = $db->prepare("SELECT * FROM colis WHERE tracking = :tracking");
        $req->bindParam(':tracking', $tracking);
        $req->execute();

        $colis = $req->fetchAll(PDO::FETCH_ASSOC);

        $response["success"] = 1;
        $response["message"] = "Détails du colis récupérés avec succès";
        $response["colis"] = $colis;
    } catch (\Throwable $th) {
        $response["success"] = 0;
        $response["message"] = "Erreur: " . $th->getMessage();
    }
} else {
    $response["success"] = 0;
    $response["message"] = "Paramètre de suivi manquant";
}

echo json_encode($response);
?>
ssss