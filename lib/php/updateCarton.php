
<?php
include "connection.php";
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $trackingCarton = $_POST['trackingCarton'];
    $etat = $_POST['etat'];
    $date = $_POST['date'];

    // Mise à jour de la table carton
    $sqlCarton = "UPDATE carton SET etat = '$etat', date_changement = '$date' WHERE trackingCarton = '$trackingCarton'";
    // ...

    // Mise à jour de la table colis associée
    $sqlColis = "UPDATE colis SET etat = '$etat', date_changement = '$date' WHERE ID IN (SELECT colis_id FROM carton_colis WHERE carton_id IN (SELECT ID FROM carton WHERE trackingCarton = '$trackingCarton'))";
    // ...

    // Mise à jour de la date de changement d'état dans la table carton-colis
    $sqlCartonColis = "UPDATE carton_colis SET date_changement = '$date' WHERE carton_id IN (SELECT ID FROM carton WHERE trackingCarton = '$trackingCarton')";
    // ...

    // Exécutez les requêtes SQL pour mettre à jour l'état du carton, des colis associés et la date de changement d'état dans la table carton-colis
    if (mysqli_query($conn, $sqlCarton) && mysqli_query($conn, $sqlColis) && mysqli_query($conn, $sqlCartonColis)) {
        echo "Mise à jour réussie";
    } else {
        echo "Échec de la mise à jour : " . mysqli_error($conn);
    }
} else {
    echo "Méthode non autorisée";
}
?>
