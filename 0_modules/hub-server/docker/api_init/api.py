from flask import Flask, request
from flask_cors import CORS
from urllib.parse import urlparse
import shutil
import os
import re
import boto3

# Retrieve the domain from an environment variable
DOMAIN_NAME = os.getenv('DNSDOMAIN', 'fortidemoscloud.com')
DNSZONEID = os.getenv('DNSZONEID', 'Z0204711R1XYLX8XRXCS')

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Function to destroy Terraform code
@app.route('/createcname', methods=['POST'])
def createcname():
    if request.content_type == 'application/json':
        # JSON request, typically from `curl -d`
        data = request.get_json()
        new_record = data.get('new_record')
        fwb_endpoint = data.get('fwb_endpoint')
    else:
        # Form data, typically from HTML form submission
        new_record = request.form.get('new_record')
        fwb_endpoint = request.form.get('fwb_endpoint')

    # Validate the inputs
    if not new_record or not fwb_endpoint:
        return "Necesito dos parámetros: new_record y fwb_endpoint"

    if not is_valid_new_record(new_record):
        return f"new_record no válido: {new_record}"
    
    if not is_valid_fqdn(fwb_endpoint):
        return f"fwb_endpoint no válido: {fwb_endpoint}"

    try:
        # Construct the CNAME record name
        new_record = f"{new_record}.{DOMAIN_NAME}"
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
        return f"CNAME created: {new_record} value: {fwb_endpoint}", 201

    except Exception as e:
        return f"error: {str(e)}", 400
    
# Function to sanitize inputs
def sanitize_input(input_string):
    # Define a regular expression patterns
    pattern = re.compile(r'[^a-zA-Z0-9.]')
    # Use the pattern to replace any unwanted characters with an empty string
    sanitized_string = re.sub(pattern, '', input_string)
    
    return sanitized_string

# Function to check fortixperts new_record
def is_valid_new_record(input_string):
    # Check if the record name starts with "fortixpert" and extract the numeric part
    new_record_regex = r'^fortixpert([1-9][0-9]?|100)(-dvwa|-api)?$'
    return re.match(new_record_regex, input_string) is not None

# Function to validate URL
def is_valid_fqdn(input_string):
    # Regular expression to validate a fully qualified domain name (FQDN)
    fqdn_regex = r'^(?!-)[A-Za-z0-9-]{1,63}(?<!-)\.(?:[A-Za-z0-9-]{2,63}\.?)+$'
    return re.match(fqdn_regex, input_string) is not None

if __name__ == '__main__':
    # Specify the desired port (e.g., 8080)
    port = 8080
    app.run(debug=False,host="0.0.0.0",port=port)