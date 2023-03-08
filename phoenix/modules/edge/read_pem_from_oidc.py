import requests
import json
import jwt
import sys
import cryptography
from cryptography.x509 import load_pem_x509_certificate
from cryptography.hazmat.primitives.serialization import Encoding, PublicFormat

from urllib.parse import urlparse

from kubernetes import client, config

# Load kubeconfig
config.load_kube_config()

# Change the default output to stderr
sys.stdout, sys.stderr = sys.stderr, sys.stdout

# Create a Kubernetes API client
api_client = client.ApiClient()

# Create an API request
api_path = '/.well-known/openid-configuration'
api_response = api_client.call_api(
    api_path, 'GET', response_type='object')

# Print the response
print('the response', api_response)

jwks_uri = api_response[0]['jwks_uri']
issuer = api_response[0]['issuer']

print(f'\njwks_uri: {jwks_uri}')
print(f'issuer: {issuer}')


# get just the path portion from the URL
jwks_uri = urlparse(jwks_uri).path

api_response = api_client.call_api(jwks_uri, 'GET', response_type='object')

print('response', api_response)

jwk_key = api_response[0].get('keys')[0]

# Parse the JWKS and extract the public key
# jwk_dict = json.loads(jwks)
# jwk_key = jwk_dict['keys'][0]
public_key = jwt.algorithms.RSAAlgorithm.from_jwk(json.dumps(jwk_key))

# Convert the public key to PEM format
pem = public_key.public_bytes(Encoding.PEM, PublicFormat.SubjectPublicKeyInfo)

# Print to the stdout
print(pem.decode('utf-8'))

# Print the public key in PEM format
# Printing to stderr since it's redirected
print(pem.decode('utf-8'), file=sys.stderr)
