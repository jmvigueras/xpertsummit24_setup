<?php
include_once 'vendor/autoload.php';

use Aws\Route53\Route53Client;
use Aws\Exception\AwsException;

$zoneId = $domainName = $regionId = $exit = "";

// Variables
$zoneId = $_ENV['DNSZONEID'];
$domainName = $_ENV['DNSDOMAIN'];
$regionId = $_ENV['AWSREGION'];

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $record = $_POST["record"];
    if (empty($record) ) {
        $exit = "New record can't be blank";
    } elseif (!isValidRecord($record)) {
        $exit = "Invalid record";
    } else {
        $exit = createCnameRecord($regionId, $zoneId, $domainName, $record);
    }
}

echo $exit;

// Function to validate correct user record
function isValidRecord($record) {
    // Regular expression pattern to match "fortixpert" followed by a number from 1 to 100
    $pattern = '/^fortixpert([1-9][0-9]?|100)$/';
    $exit = false;

    // Perform the match
    if (preg_match($pattern, $record)) {
        $exit = true;
    }
    return $exit;
}
// Function to create the new record
function createCnameRecord($regionId, $zoneId, $domainName, $record) {
    // Create an AWS Route53 client
    $client = new Route53Client([
        'version' => 'latest',
        'region'  => $regionId // Change region if necessary
    ]);

    try {
        // Define the change for the CNAME record
        $client->changeResourceRecordSets([
            'HostedZoneId' => $zoneId,
            'ChangeBatch' => [
                'Changes' => [
                    [
                        'Action' => 'CREATE',
                        'ResourceRecordSet' => [
                            'Name' => $domainName,
                            'Type' => 'CNAME',
                            'TTL' => 300,
                            'ResourceRecords' => [
                                [
                                    'Value' => $record
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]);
        $exit = "CNAME record created successfully:" . $record . "." . $domainName;
    } catch (AwsException $e) {
        $exit = "Error creating CNAME record: " . $e->getMessage();
    }
    return $exit;
}