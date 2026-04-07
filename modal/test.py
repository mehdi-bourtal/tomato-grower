# test.py
import requests
import json

URL = "https://mehdi-bourtal69--tomato-grower-app-run-pipeline.modal.run"

test_payload = {
    "proc_id": "6c9e56c4-ceae-4088-b77b-bb2d034413a0",  # ← mets ton vrai proc_id complet
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
print("Réponse brute:", response.text)

# Essaie de parser en JSON seulement si la réponse n'est pas vide
if response.text:
    try:
        print("Réponse JSON:")
        print(json.dumps(response.json(), indent=2))
    except Exception as e:
        print("Impossible de parser en JSON:", e)