include "connection.php";

$response = [];

try {
    $sql = "SELECT * FROM colis WHERE 1=1"; // Utilisation de "1=1" pour construire la requête SQL de manière conditionnelle

    if (isset($_GET['etat'])) {
        $etat = $_GET['etat'];
        $sql .= " AND etat = '$etat'";
    }

    if (isset($_GET['modeEnvoie'])) {
        $modeEnvoie = $_GET['modeEnvoie'];
        $sql .= " AND modeEnvoie = '$modeEnvoie'";
    }

    if (isset($_GET['codeClient'])) {
        $codeClient = $_GET['codeClient'];
        $sql .= " AND codeClient = '$codeClient'";
    }

    $req = $db->query($sql);
    $colis = $req->fetchAll(PDO::FETCH_ASSOC);

    $response["success"] = 1;
    $response["message"] = "Liste des colis récupérée avec succès";
    $response["colis"] = $colis;
} catch (\Throwable $th) {
    $response["success"] = 0;
    $response["message"] = "Erreur: " . $th->getMessage();
}

echo json_encode($response);
