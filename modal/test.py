# test.py
import json
from pathlib import Path

import requests

# Endpoint JSON existant (pipeline capteurs)
PIPELINE_URL = "https://mehdi-bourtal69--tomato-grower-app-run-pipeline.modal.run"

# Endpoint multipart du détecteur de tomates (à adapter après deploy)
DETECTOR_URL = "https://mehdi-bourtal69--tomato-detector-detect-ripe-tomatoes.modal.run"

TEST_PROC_ID = "6c9e56c4-ceae-4088-b77b-bb2d034413a0"
TEST_IMAGE_PATH = Path(__file__).resolve().parent / "images.jpeg"


def test_pipeline_endpoint() -> None:
    """Test historique: endpoint JSON du pipeline."""
    payload = {
        "proc_id": TEST_PROC_ID,
        "temperature": 20,
        "humidity_int": 55,
        "humidity_ext": 67,
        "luminosity": 6600,
    }
    try:
        response = requests.post(
            PIPELINE_URL,
            headers={"Content-Type": "application/json"},
            json=payload,
            timeout=30,
        )
        print("\n=== TEST PIPELINE JSON ===")
        print("Status code:", response.status_code)
        print("Réponse brute:", response.text)
        try:
            print("Réponse JSON:")
            print(json.dumps(response.json(), indent=2, ensure_ascii=False))
        except Exception as exc:
            print("Impossible de parser en JSON:", exc)
    except requests.exceptions.Timeout:
        print("Erreur : la requête pipeline a expiré.")
    except requests.exceptions.RequestException as exc:
        print("Erreur réseau pipeline:", exc)


def test_detector_endpoint_with_image() -> None:
    """
    Nouveau test: endpoint détecteur (multipart/form-data)
    avec l'image modal/images.jpeg.
    """
    if "<your-username>" in DETECTOR_URL:
        print("\n[SKIP] Renseigne DETECTOR_URL avec l'URL réelle du endpoint Modal.")
        return

    if not TEST_IMAGE_PATH.exists():
        print(f"\n[ERREUR] Image introuvable: {TEST_IMAGE_PATH}")
        return

    try:
        with TEST_IMAGE_PATH.open("rb") as f:
            files = {"image": ("images.jpeg", f, "image/jpeg")}
            data = {"proc_id": TEST_PROC_ID}
            response = requests.post(
                DETECTOR_URL,
                data=data,
                files=files,
                timeout=60,
            )

        print("\n=== TEST DETECTOR MULTIPART ===")
        print("Status code:", response.status_code)
        print("Réponse brute:", response.text)
        try:
            print("Réponse JSON:")
            print(json.dumps(response.json(), indent=2, ensure_ascii=False))
        except Exception as exc:
            print("Impossible de parser en JSON:", exc)
    except requests.exceptions.Timeout:
        print("Erreur : la requête detector a expiré.")
    except requests.exceptions.RequestException as exc:
        print("Erreur réseau detector:", exc)


if __name__ == "__main__":
    test_pipeline_endpoint()
    test_detector_endpoint_with_image()