<?php

// Inclure le fichier de connexion à la base de données
include 'connection.php';

// Récupérer le code-barres depuis la requête HTTP GET
$barcode = $_GET["barcode"];

// Éviter les attaques d'injection SQL (vous devriez utiliser des requêtes préparées dans un environnement de production)
$barcode = htmlspecialchars($barcode);
$barcode = $conn->quote($barcode);

// Exécuter la requête SQL pour récupérer les données du colis en fonction du code-barres
$sql = "SELECT * FROM colisClient WHERE tracking = $barcode";
$result = $conn->query($sql);

// Vérifier si des résultats ont été trouvés
if ($result->rowCount() > 0) {
    // Récupérer la première ligne de résultats
    $row = $result->fetch(PDO::FETCH_ASSOC);

    // Construire un tableau associatif à renvoyer en tant que réponse JSON
    $response = array(
        "codeClient" => $row["codeClient"],
        "modeEnvoi" => $row["modeEnvoi"]
    );

    // Renvoyer la réponse au format JSON
    header('Content-Type: application/json');
    echo json_encode($response);
} else {
    // Aucun résultat trouvé pour le code-barres donné
    echo json_encode(array("error" => "Barcode not found"));
}

// Fermer la connexion à la base de données
$db = null;

?>
