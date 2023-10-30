<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include "connection.php"; // Include your database connection code

// Check if the request method is POST
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Handle POST data sent from the Flutter application
    $data = json_decode(file_get_contents("php://input"));

    // Validate the data as needed
    if (empty($data->trackingCarton) || empty($data->etat) || empty($data->trackingColis)) {
        http_response_code(400); // Bad Request
        echo json_encode(["error" => "Incomplete data provided"]);
        exit();
    }

    // Insert the carton data into the database
    $query = "INSERT INTO carton (trackingCarton, etat) VALUES (:trackingCarton, :etat)";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":trackingCarton", $data->trackingCarton);
    $stmt->bindParam(":etat", $data->etat);

    if ($stmt->execute()) {
        // Record inserted successfully
        $carton_id = $db->lastInsertId();

        // Now, insert the trackingColis into a separate table (assuming you have a separate table for trackingColis)
        $trackingColis = $data->trackingColis;
        foreach ($trackingColis as $tracking) {
            $query = "INSERT INTO colis_carton (carton_id, tracking) VALUES (:carton_id, :tracking)";
            $stmt = $db->prepare($query);
            $stmt->bindParam(":carton_id", $carton_id);
            $stmt->bindParam(":tracking", $tracking);
            $stmt->execute();
        }

        http_response_code(201); // Created
        echo json_encode(["message" => "Carton and trackingColis added successfully"]);
    } else {
        http_response_code(500); // Internal Server Error
        echo json_encode(["error" => "Failed to insert carton data"]);
    }
} else {
    http_response_code(405); // Method Not Allowed
    echo json_encode(["error" => "Method not allowed"]);
}
?>
