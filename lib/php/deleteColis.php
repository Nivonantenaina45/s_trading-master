<?php
include "connection.php";

if ($_SERVER['REQUEST_METHOD'] == 'DELETE') {
    // Récupérez l'ID de l'élément à supprimer depuis les paramètres de la requête
    parse_str(file_get_contents('php://input'), $data);
    $colisId = $data['id'];

    // Vérifiez que l'ID est valide (vous pouvez ajouter d'autres vérifications ici)
    if (is_numeric($colisId)) {
        // Exécutez la requête de suppression dans la base de données
        $sql = "DELETE FROM colis WHERE id = ?";
        try {
            $stmt = $db->prepare($sql);
            $stmt->execute([$colisId]);
            echo json_encode(['success' => true, 'message' => 'Colis supprimé avec succès']);
        } catch (PDOException $e) {
            echo json_encode(['success' => false, 'message' => 'Échec de la suppression du colis : ' . $e->getMessage()]);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'ID invalide']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Méthode de requête invalide']);
}
?>
