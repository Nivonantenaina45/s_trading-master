<?php
include "connection.php";

if ($_SERVER['REQUEST_METHOD'] == 'GET') { // Utilisez une méthode GET pour récupérer les données
    // Récupération des données de la table "carton"
    $sql_carton = "SELECT trackingCarton, etat FROM carton";
    $result_carton = $db->query($sql_carton);
    $carton_data = $result_carton->fetch_all(MYSQLI_ASSOC);

    // Récupération des données de la table "carton_colis"
    $sql_carton_colis = "SELECT trackingCarton, trackingColis FROM carton_colis";
    $result_carton_colis = $db->query($sql_carton_colis);
    $carton_colis_data = $result_carton_colis->fetch_all(MYSQLI_ASSOC);

    $response = [
        "success" => 1,
        "carton" => $carton_data,
        "carton_colis" => $carton_colis_data
    ];

    echo json_encode($response);
}
?>
