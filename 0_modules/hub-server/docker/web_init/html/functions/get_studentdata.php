<?php
// define variables and set to empty values
$email = $exit = "";
$dbhost = $dbuser = $dbpass = $db = $table = $mysqli = $sql = $result = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if (empty($_POST["email"])) {
        $exit = "Email is required";
    } else {
        $email = $_POST['email'];
        // check if e-mail address is well-formed
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
          $exit = "Invalid email format";
        } else {
            // Get environment variables
            $dbhost = $_ENV['DBHOST'];
            $dbuser = $_ENV['DBUSER'];
            $dbpass = $_ENV['DBPASS'];
            $db = $_ENV['DBNAME'];
            $table = $_ENV['DBTABLE'];

            $con = mysqli_connect($dbhost,$dbuser,$dbpass,$db);
            if (mysqli_connect_errno()) {
                $exit = "Error: connecting DB: ". mysqli_connect_error();
            } else {
                $exit = "User not found";
                $sql = "SELECT * FROM " . $table ." WHERE email='".$email."'";
                if ($result = mysqli_query($con,$sql)) {
                    while($row = mysqli_fetch_array($result))
                    {
                        $exit = '<p>';
                        $exit .= '<b>Usuario de laboratorio:</b>';
                        $exit .= '</p>';
                        $exit .= '  aws_user_id = "' . $row['aws_user_id'] . '"<br>';
                        $exit .= '<p>';
                        $exit .= '<b>Acceso a FortiWEB Cloud y FortiGSLB (IAM login):</b>';
                        $exit .= '</p>';
                        $exit .= '  accountid  = "' . $row['accountid'] . '"<br>';
                        $exit .= '  user_id = "' . $row['forticloud_user'] . '"<br>';
                        $exit .= '  user_password = "' . $row['forticloud_password'] . '"<br>';
                        $exit .= '<p>';
                        $exit .= '<b>Acceso a tu FortiGate:</b>';
                        $exit .= '</p>';
                        $exit .= '  fgt_url  = https://' . $row['fgt_ip'] . ':8443 <br>';
                        $exit .= '  fgt_user = "' . $row['fgt_user'] . '"<br>';
                        $exit .= '  fgt_pass = "' . $row['fgt_password'] . '"<br>';
                        $exit .= '  fgt_api_key = "' . $row['fgt_api_key'] . '"<br>';
                        $exit .= '<p>';
                        $exit .= '<b>Acceso a tu FortiADC:</b>';
                        $exit .= '</p>';
                        $exit .= '  fad_url = https://' . $row['fgt_ip'] . ':8444 <br>';
                        $exit .= '  fad_user = "' . $row['fad_user'] . '"<br>';
                        $exit .= '  fad_pass = "' . $row['fad_password'] . '"<br>';
                        $exit .= '  fad_ip = "' . $row['fad_ip'] . '"<br>';
                        $exit .= '  fad_ip_nat = "' . $row['fad_ip_nat'] . '"<br>';
                        $exit .= '<p>';
                        $exit .= '<b>Acceso a tus aplicaciones a través de FortiGate: </b>';
                        $exit .= '</p>';
                        $exit .= '  dvwa_url  = http://' . $row['fgt_ip'] . ':31000 <br>';
                        $exit .= '  swagger_url  = http://' . $row['fgt_ip'] . ':31001 <br>';
                        $exit .= '<p>';
                        $exit .= '<b>Acceso a tus aplicaciones a través de FortiADC: </b>';
                        $exit .= '</p>';
                        $exit .= '  dvwa_url  = http://' . $row['fgt_ip'] . ':31010 <br>';
                        $exit .= '  swagger_url  = http://' . $row['fgt_ip'] . ':31011 <br>';
                        $exit .= '<p>';
                        $exit .= '<b>Servidor de laboratorio:</b>';
                        $exit .= '</p>';
                        $exit .= '  IP: "' . $row['server_ip'] . '"<br>';
                        $exit .= '  Kubernetes connector secret token: <br>';
                        $exit .= '  <textarea readonly>' . $row['k8s_sdn_token'] . '</textarea>';
                        $exit .= '<p>';
                        $exit .= '<b>Acceso lectura a HUB A-A cloud y HUB OnPrem:</b>';
                        $exit .= '</p>';
                        $exit .= '  fgt_url_cloud  = https://hub1.fortidemoscloud.com:8443 <br>';
                        $exit .= '  fgt_url_onprem = https://hub2.fortidemoscloud.com:8443 <br>';
                        $exit .= '  fgt_user = "xperts"<br>';
                        $exit .= '  fgt_pass = "' . $row['fad_password'] . '"<br>';
                        $exit .= '<p>';
                        $exit .= '<p>';
                    }
                }
            }
            mysqli_close($con);
        }
    }
}
echo $exit;
