<?php
include "connection.php";

$response = [];

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $trackingCarton = $_POST['trackingCarton'];
    $trackingColis = $_POST['trackingColis'];

    try {
        // Récupérer l'id du carton en fonction du trackingCarton
        $stmt = $db->prepare("SELECT id FROM carton WHERE trackingCarton = ?");
        $stmt->execute([$trackingCarton]);
        $cartonId = $stmt->fetchColumn();

        if ($cartonId) {
            // Ajouter le colis au carton_colis
            $stmt = $db->prepare("INSERT INTO carton_colis (trackingColis, carton_id) VALUES (?, ?)");
            $stmt->execute([$trackingColis, $cartonId]);

            $response["success"] = 1;
            $response["message"] = "Colis ajouté au carton avec succès";
        } else {
            $response["success"] = 0;
            $response["message"] = "Carton non trouvé avec le tracking spécifié";
        }
    } catch (\Throwable $th) {
        $response["success"] = 0;
        $response["message"] = "Erreur: " . $th->getMessage();
    }
} else {
    $response["success"] = 0;
    $response["message"] = "Méthode non autorisée";
}

echo json_encode($response);
?>
