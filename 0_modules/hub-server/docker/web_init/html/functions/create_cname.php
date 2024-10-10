<?php

// Functions
function createcname($url, $user_id, $fwb_endpoint) {
    // Prepare data to send in POST request
    $data = array(
        'user_id' => $user_id,
        'fwb_endpoint' => $fwb_endpoint
    );

    // Initialize cURL session
    $ch = curl_init($url);

    // Configure cURL options
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));

    // Convert data array to JSON
    $json_data = json_encode($data);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $json_data);

    // Execute cURL request
    $response = curl_exec($ch);

    // Check for errors
    if (curl_errno($ch)) {
        echo 'cURL error: ' . curl_error($ch);
        return false;
    }

    // Close cURL session
    curl_close($ch);

    // Return the response from Flask server
    return $response;
}

// Variables
$url = 'http://api:8080/createcname';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    echo createcname($url, $_POST["user_id"], $_POST["fwb_endpoint"]);
} else {
    echo "Method not allowed";
}
