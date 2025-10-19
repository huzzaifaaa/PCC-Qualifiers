#!/usr/bin/env python3

from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
import base64
import json
import time

# The hardcoded key from the Java code
SECRET_KEY = b"PCC25PREMIUM#1A2"

def encrypt_license(data):
    """Encrypt license data using AES/ECB/PKCS5Padding"""
    cipher = AES.new(SECRET_KEY, AES.MODE_ECB)
    json_data = json.dumps(data)
    padded_data = pad(json_data.encode('utf-8'), AES.block_size)
    encrypted = cipher.encrypt(padded_data)
    return base64.b64encode(encrypted).decode('utf-8')

def decrypt_license(encrypted_license):
    """Decrypt license key to see what's inside"""
    cipher = AES.new(SECRET_KEY, AES.MODE_ECB)
    encrypted_bytes = base64.b64decode(encrypted_license)
    decrypted = cipher.decrypt(encrypted_bytes)
    unpadded = unpad(decrypted, AES.block_size)
    return json.loads(unpadded.decode('utf-8'))

def generate_valid_license(years=10):
    """Generate a valid premium license"""
    # Calculate future timestamp (10 years from now)
    future_timestamp = int(time.time()) + (years * 365 * 24 * 60 * 60)
    
    license_data = {
        "ispremium": True,
        "isnoob": True,
        "valid_until": future_timestamp
    }
    
    return encrypt_license(license_data)

def main():
 
 
    valid_license = generate_valid_license()
    
    print(f" New Premium License Key:")
    print(f"    {valid_license}")
    print()
   

if __name__ == "__main__":
    main()