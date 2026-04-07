# test.py
import requests
import json

URL = "https://mehdi-bourtal69--tomato-grower-app-run-pipeline.modal.run"

test_payload = {
    "proc_id": "6c9e56c4-ceae-4088-b77b-bb2d034413a0",
    "temperature": 20,
    "humidity_int": 55,
    "humidity_ext": 67,
    "luminosity": 6600,
}

try:
    response = requests.post(
        URL,
        headers={"Content-Type": "application/json"},
        json=test_payload,
        timeout=30,
    )

    print("Status code:", response.status_code)
    print("Réponse brute:", response.text)

    try:
        print("Réponse JSON:")
        print(json.dumps(response.json(), indent=2, ensure_ascii=False))
    except Exception as e:
        print("Impossible de parser en JSON:", e)

except requests.exceptions.Timeout:
    print("Erreur : la requête a expiré.")
except requests.exceptions.RequestException as e:
    print("Erreur réseau :", e)