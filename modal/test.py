# test.py
import requests
import json

URL = "https://mehdi-bourtal69--tomato-grower-app-run-pipeline.modal.run"

test_payload = {
    "proc_id": "4eaz-yhe09-IOL9U7",
    "temperature": 20,
    "humidity_int": 55,
    "humidity_ext": 67,
    "luminosity": 6600,
}

response = requests.post(
    URL,
    headers={"Content-Type": "application/json"},
    json=test_payload,
)

print("Status code:", response.status_code)
print("Réponse:")
print(json.dumps(response.json(), indent=2))