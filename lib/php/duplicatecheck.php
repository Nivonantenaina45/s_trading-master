<?php
include "connection.php";

$response = [];

// Assuming you have received the tracking code in the request
$trackingCode = $_POST['tracking']; // Adjust based on how the tracking code is sent

try {
    // Check if the tracking code already exists
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM colis WHERE tracking = ?");
    $stmt->execute([$trackingCode]);
    $count = $stmt->fetchColumn();

    if ($count > 0) {
        // Tracking code already exists, send an error response
        $response["success"] = 0;
        $response["message"] = "Tracking code already exists";
    } else {
        // Tracking code doesn't exist, proceed with inserting the new colis
        $stmt = $db->prepare("INSERT INTO colis (tracking, other_columns) VALUES (?, ?)");
        $stmt->execute([$trackingCode, /* other values */]);

        $response["success"] = 1;
        $response["message"] = "Colis inserted successfully";
    }
} catch (\Throwable $th) {
    // Handle database or other errors
    $response["success"] = 0;
    $response["message"] = "Error: " . $th->getMessage();
}

echo json_encode($response);
?>
