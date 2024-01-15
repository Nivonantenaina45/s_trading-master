<?php
// Inclure le fichier de connexion
include 'connection.php';

// Récupérer les données de la requête POST
$trackingCarton = $_POST['trackingCarton'];

try {
    // Préparer et exécuter la requête de suppression du carton
    $stmt = $pdo->prepare("DELETE FROM carton WHERE trackingCarton = :trackingCarton");
    $stmt->bindParam(':trackingCarton', $trackingCarton, PDO::PARAM_STR);
    $stmt->execute();

    // Réponse en cas de succès
    echo "Carton supprimé avec succès";
} catch (PDOException $e) {
    // Réponse en cas d'échec
    echo "Erreur lors de la suppression du carton: " . $e->getMessage();
}
?>
