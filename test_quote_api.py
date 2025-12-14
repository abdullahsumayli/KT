#!/usr/bin/env python3
import requests
import json

url = "http://127.0.0.1:8000/api/v1/quotes/"
data = {
    "style": "modern",
    "city": "riyadh",
    "phone": "0512345678"
}

print("Testing Quote API...")
print(f"URL: {url}")
print(f"Data: {json.dumps(data, indent=2)}")
print("-" * 50)

try:
    response = requests.post(url, json=data)
    print(f"Status Code: {response.status_code}")
    print("Response:")
    print(json.dumps(response.json(), indent=2, ensure_ascii=False))
except Exception as e:
    print(f"Error: {e}")
