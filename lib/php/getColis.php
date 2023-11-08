<?php
include "connection.php";

$response = [];

try {
    $req = $db->query("SELECT * FROM colis");
    $colis = $req->fetchAll(PDO::FETCH_ASSOC);

    $response["success"] = 1;
    $response["message"] = "Liste des colis récupérée avec succès";
    $response["colis"] = $colis;
} catch (\Throwable $th) {
    $response["success"] = 0;
    $response["message"] = "Erreur: " . $th->getMessage();
}

echo json_encode($response);
?>
