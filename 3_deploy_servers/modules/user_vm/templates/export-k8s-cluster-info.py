# --------------------------------------------------------------------------------------------
# Populate cluster data to Redis DB
#
# jvigueras@fortinet.com
# --------------------------------------------------------------------------------------------
import redis
import kubernetes
import time
from kubernetes import client, config
from base64 import b64decode

def get_bootstrap_token_ttl0():
    """ Function to retrieve the token with no expiration """
    kube_client = client.CoreV1Api()
    secrets = kube_client.list_namespaced_secret("kube-system", field_selector='type=bootstrap.kubernetes.io/token').items
    
    for secret in secrets:
        data = secret.data # Retrieve the data from the secret
        token_id = b64decode(data.get('token-id')).decode('utf-8')
        token_secret = b64decode(data.get('token-secret')).decode('utf-8')
        expiration = data.get('expiration')
        if expiration is None:  # Token without expiration
            token = f"{token_id}.{token_secret}"
            return token
    
    return None

def get_bootstrap_token():
    """ Get the token id from the Kubernetes cluster """
    kube_client = client.CoreV1Api()
    master_tokens = kube_client.list_namespaced_secret("kube-system", field_selector='type=bootstrap.kubernetes.io/token').items
    master_token_id = b64decode(master_tokens[0].data["token-id"]).decode('utf-8')
    master_token_secret = b64decode(master_tokens[0].data["token-secret"]).decode('utf-8')
    return  f"{master_token_id}.{master_token_secret}"

def get_cicd_token():
    """ Get the CICD token from the Kubernetes cluster """
    kube_client = client.CoreV1Api()
    cicd_token = kube_client.read_namespaced_secret(name="cicd-access", namespace="default").data["token"]
    cicd_token_decode = b64decode(cicd_token).decode()
    return cicd_token_decode

def get_cicd_cert():
    """ Get the CICD certificate from the Kubernetes cluster """
    kube_client = client.CoreV1Api()
    cicd_cert = kube_client.read_namespaced_secret(name="cicd-access", namespace="default").data["ca.crt"]
    return cicd_cert

def connect_db(host, port, password):
    """ Connect to Redis DB """
    try:
        r = redis.Redis(host=host, port=port, password=password)
        return r
    except Exception as e:
        print(f"Failed to connect to Redis: {e}")
        return None

def write_db(db_conn, key_value_pairs):
    """ Write key-value pairs to Redis """
    try:
        for key, value in key_value_pairs.items():
            db_conn.set(key, value)
    except Exception as e:
        print(f'Error writing key-value pairs to Redis: {e}')
        return None

def main():
    try:
       # Script template variables (update with Terraform datatemplate)
        master_ip = '${master_ip}'
        master_api_port = '${master_api_port}'
        db_host = '${db_host}'
        db_port = '${db_port}'
        db_pass = '${db_pass}'
        prefix  = '${prefix}'
 
        # Load the Kubernetes configuration
        config.load_kube_config()

        # Get the tokens and certificate from Kubernetes
        cicd_token = get_cicd_token()
        cicd_cert = get_cicd_cert()
        master_token = get_bootstrap_token_ttl0()
        master_host = f"{master_ip}:{master_api_port}"

        # Wait for Redis to be ready
        db_conn = None
        while db_conn is None:
            print("Attempting to connect to Redis...")
            db_conn = connect_db(db_host, db_port, db_pass)
            if db_conn is None:
                print("Retrying in 5 seconds...")
                time.sleep(5)
                
        # Define the key-value pairs to write
        key_value_pairs = {
                f"{prefix}_sdn_token": cicd_token,
                f"{prefix}_ca_cert" : cicd_cert,
                f"{prefix}_master_token": master_token,
                f"{prefix}_master_host" : master_host,
        }
        
        # Write key-pairs to Redis DB
        write_db(db_conn,key_value_pairs)

    except Exception as e:
        print(f"Failed to execute main function: {e}")

if __name__ == '__main__':
    main()