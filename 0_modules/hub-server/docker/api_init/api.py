from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
from urllib.parse import urlparse
import shutil
import os
import re
import boto3

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Retrieve the domain from an environment variable
DOMAIN_NAME = os.getenv('DNSDOMAIN', 'fortidemoscloud.com')
DNSZONEID = os.getenv('DNSZONEID', 'Z0204711R1XYLX8XRXCS')

# Function to sanitize inputs
def sanitize_input(input_string):
    # Define a regular expression patterns
    pattern = re.compile(r'[^a-zA-Z0-9.]')
    # Use the pattern to replace any unwanted characters with an empty string
    sanitized_string = re.sub(pattern, '', input_string)
    
    return sanitized_string

# Function to check fortixperts user_id
def is_valid_user_id(input_string):
    # Check if the record name starts with "fortixpert" and extract the numeric part
    user_id_regex = r'^fortixpert(\d+)$'
    return re.match(user_id_regex, input_string) is not None

# Function to validate URL
def is_valid_fqdn(input_string):
    # Regular expression to validate a fully qualified domain name (FQDN)
    fqdn_regex = r'^(?!-)[A-Za-z0-9-]{1,63}(?<!-)\.(?:[A-Za-z0-9-]{2,63}\.?)+$'
    return re.match(fqdn_regex, input_string) is not None

@app.route('/')
def index():
   return render_template('index.html'), 201

# Function to destroy Terraform code
@app.route('/createcname', methods=['POST'])
def create_record():
    output = ""
    try:
        user_id = sanitize_input(request.form['user_id'])
        fwb_endpoint = sanitize_input(request.form['fwb_endpoint'])

        if not is_valid_user_id(user_id):
            output = f"user_id no válido: {user_id}"
            if not is_valid_fqdn(fwb_endpoint):
                output = f"FWB CNAME no válido: {fwb_endpoint}"
            else:
                # Construct the CNAME record name
                new_record = f"{user_id}.{DOMAIN_NAME}"

                # Initialize Route 53 client
                route53 = boto3.client('route53')

                # Create CNAME record
                response = route53.change_resource_record_sets(
                    HostedZoneId=DNSZONEID,
                    ChangeBatch={
                        'Changes': [
                            {
                                'Action': 'CREATE',
                                'ResourceRecordSet': {
                                    'Name': new_record,
                                    'Type': 'CNAME',
                                    'TTL': 300,
                                    'ResourceRecords': [{'Value': fwb_endpoint}]
                                }
                            }
                        ]
                    }
                )
                output = f"CNAME record created successfully, response: {response}", 201

        return output
    
    except Exception as e:
        return f"error': {str(e)}", 400


if __name__ == '__main__':
    # Specify the desired port (e.g., 8080)
    port = 8080
    app.run(debug=True,host="0.0.0.0",port=port)