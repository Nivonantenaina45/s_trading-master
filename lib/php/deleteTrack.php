<?php
include "connection.php";

$response = [];

if (isset($_GET['trackingColis'])) {
    $trackingColis = $_GET['trackingColis'];

    try {
        $stmt = $db->prepare("DELETE FROM carton_colis WHERE trackingColis = :trackingColis");
        $stmt->bindParam(':trackingColis', $trackingColis);
        $stmt->execute();

        $response["success"] = 1;
        $response["message"] = "TrackingColis supprimé avec succès";
    } catch (\Throwable $th) {
        $response["success"] = 0;
        $response["message"] = "Erreur: " . $th->getMessage();
    }
} else {
    $response["success"] = 0;
    $response["message"] = "Paramètre trackingColis manquant";
}

echo json_encode($response);
?>
