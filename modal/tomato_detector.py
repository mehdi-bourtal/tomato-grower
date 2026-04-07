"""
tomato_detector.py
==================
Endpoint Modal : détecte les tomates mûres sur une image Supabase via
analyse de contours rouges (OpenCV), puis insère un bilan dans `tomatos_status`.

Déploiement :
    modal deploy modal/tomato_detector.py

Variables requises dans le secret Modal "my-secrets" :
    SUPABASE_URL          – URL REST Supabase
    SUPABASE_SERVICE_KEY  – clé service Supabase (rôle service_role)

Appel HTTP :
    POST <endpoint_url>
    Content-Type: application/json
    {
        "proc_id":        "<uuid>",
        "img_supabase_url": "<URL publique ou signée de l'image>"
    }
"""

import modal
import os

# ---------------------------------------------------------------------------
# Image Docker – dépendances Python installées au build
# ---------------------------------------------------------------------------
image = (
    modal.Image.debian_slim()
    # Bibliothèques système nécessaires à OpenCV (headless)
    .apt_install("libglib2.0-0", "libgl1")
    .pip_install(
        "requests",
        "numpy",
        "opencv-python-headless",   # OpenCV sans GUI
        "fastapi[standard]",
        "python-dotenv",
    )
)

app = modal.App("tomato-detector")

# ---------------------------------------------------------------------------
# Codes d'erreur métier renvoyés en JSON
# ---------------------------------------------------------------------------
ERR_MISSING_PARAM   = "MISSING_PARAMETER"
ERR_INVALID_URL     = "INVALID_IMAGE_URL"
ERR_DOWNLOAD_FAILED = "IMAGE_DOWNLOAD_FAILED"
ERR_DECODE_FAILED   = "IMAGE_DECODE_FAILED"
ERR_SUPABASE_INSERT = "SUPABASE_INSERT_FAILED"
ERR_INTERNAL        = "INTERNAL_ERROR"


def _error(code: str, detail: str, status: int = 400) -> dict:
    """Construit une réponse d'erreur normalisée."""
    return {"error": code, "detail": detail, "status": status}


# ---------------------------------------------------------------------------
# Étape 1 – Téléchargement de l'image
# ---------------------------------------------------------------------------
def download_image(url: str) -> bytes:
    """
    Télécharge l'image depuis l'URL fournie.

    Raises:
        ValueError  – si l'URL est vide ou invalide (non HTTP).
        RuntimeError – si le serveur répond avec un code != 200.
    """
    import requests

    if not url or not url.startswith("http"):
        raise ValueError(f"URL invalide ou vide : '{url}'")

    try:
        resp = requests.get(url, timeout=15)
    except requests.exceptions.RequestException as exc:
        raise RuntimeError(f"Erreur réseau lors du téléchargement : {exc}") from exc

    if resp.status_code != 200:
        raise RuntimeError(
            f"Le serveur a répondu {resp.status_code} pour l'URL : {url}"
        )

    return resp.content


# ---------------------------------------------------------------------------
# Étape 2 – Détection des tomates mûres (ronds rouges)
# ---------------------------------------------------------------------------
def count_ripe_tomatoes(image_bytes: bytes) -> int:
    """
    Compte les tomates mûres sur l'image en cherchant des contours
    rouges et circulaires via OpenCV.

    Stratégie :
        1. Décode l'image en mémoire (BGR).
        2. Convertit en HSV.
        3. Isole les teintes rouges (deux plages HSV : 0-10 et 160-180).
        4. Applique une fermeture morphologique pour boucher les trous.
        5. Détecte les contours et filtre par circularité et surface minimale.

    Returns:
        Nombre entier de tomates mûres détectées (≥ 0).

    Raises:
        RuntimeError – si l'image ne peut pas être décodée.
    """
    import numpy as np
    import cv2

    # Décodage de l'image depuis ses octets
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if img is None:
        raise RuntimeError(
            "Impossible de décoder l'image (format non supporté ou fichier corrompu)."
        )

    # Conversion BGR → HSV (plus robuste pour la détection de couleur)
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # Plages HSV pour le rouge (deux intervalles car le rouge est circulaire en HSV)
    lower_red1 = np.array([0,   80, 60])
    upper_red1 = np.array([10, 255, 255])
    lower_red2 = np.array([160, 80, 60])
    upper_red2 = np.array([180, 255, 255])

    mask1 = cv2.inRange(hsv, lower_red1, upper_red1)
    mask2 = cv2.inRange(hsv, lower_red2, upper_red2)
    red_mask = cv2.bitwise_or(mask1, mask2)

    # Fermeture morphologique pour supprimer le bruit et remplir les trous
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9))
    red_mask = cv2.morphologyEx(red_mask, cv2.MORPH_CLOSE, kernel, iterations=2)
    red_mask = cv2.morphologyEx(red_mask, cv2.MORPH_OPEN,  kernel, iterations=1)

    # Détection des contours sur le masque binaire
    contours, _ = cv2.findContours(
        red_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
    )

    # Surface minimale d'un blob pour être considéré comme une tomate
    # (calibré pour des images 640×480 ; ajuster si nécessaire)
    MIN_AREA = 300

    ripe_count = 0
    for cnt in contours:
        area = cv2.contourArea(cnt)
        if area < MIN_AREA:
            continue  # trop petit, ignoré

        # Circularité = 4π·A / P²  (1.0 = cercle parfait)
        perimeter = cv2.arcLength(cnt, True)
        if perimeter == 0:
            continue
        circularity = 4 * np.pi * area / (perimeter ** 2)

        # On accepte les formes suffisamment rondes (seuil ≥ 0.45)
        if circularity >= 0.45:
            ripe_count += 1

    return ripe_count


# ---------------------------------------------------------------------------
# Étape 3 – Insertion dans Supabase
# ---------------------------------------------------------------------------
def insert_tomato_status(
    proc_id: str,
    img_supabase_url: str,
    ripe_tomatos: int,
    supabase_url: str,
    supabase_key: str,
) -> None:
    """
    Insère une ligne dans la table `tomatos_status` via l'API REST Supabase.

    Raises:
        RuntimeError – si l'insertion échoue (code HTTP != 201).
    """
    import requests
    from datetime import datetime, timezone

    headers = {
        "apikey": supabase_key,
        "Authorization": f"Bearer {supabase_key}",
        "Content-Type":  "application/json",
        "Prefer":        "return=minimal",
    }

    payload = {
        "proc_id":         proc_id,
        "img_supabase_url": img_supabase_url,
        "ripe_tomtatos":   ripe_tomatos,   # nom de colonne tel que dans le schéma
        "date":            datetime.now(timezone.utc).isoformat(),
    }

    resp = requests.post(
        f"{supabase_url}/rest/v1/tomatos_status",
        headers=headers,
        json=payload,
        timeout=10,
    )

    if resp.status_code not in (200, 201):
        raise RuntimeError(
            f"Supabase a répondu {resp.status_code} : {resp.text}"
        )


# ---------------------------------------------------------------------------
# Endpoint Modal
# ---------------------------------------------------------------------------
@app.function(
    image=image,
    secrets=[modal.Secret.from_name("my-secrets")],
    # Timeout généreux pour les grosses images
    timeout=120,
)
@modal.fastapi_endpoint(method="POST")
def detect_ripe_tomatoes(payload: dict) -> dict:
    """
    Endpoint POST – analyse une image et enregistre le résultat.

    Corps JSON attendu :
        proc_id         (str, requis)  – UUID du processeur
        img_supabase_url (str, requis) – URL publique/signée de l'image

    Retourne :
        {
            "proc_id":          "...",
            "img_supabase_url": "...",
            "ripe_tomatos":     <int>,
            "status":           "ok"
        }
        ou un objet d'erreur { "error": "CODE", "detail": "...", "status": <int> }.
    """
    # --- Récupération des credentials ---
    supabase_url = os.getenv("SUPABASE_URL")
    supabase_key = os.getenv("SUPABASE_SERVICE_KEY")

    if not supabase_url or not supabase_key:
        return _error(
            ERR_INTERNAL,
            "SUPABASE_URL ou SUPABASE_SERVICE_KEY manquant dans les secrets Modal.",
            status=500,
        )

    # --- Validation des paramètres d'entrée ---
    proc_id = payload.get("proc_id", "").strip()
    img_url  = payload.get("img_supabase_url", "").strip()

    if not proc_id:
        return _error(ERR_MISSING_PARAM, "Le paramètre 'proc_id' est requis.")
    if not img_url:
        return _error(ERR_MISSING_PARAM, "Le paramètre 'img_supabase_url' est requis.")
    if not img_url.startswith("http"):
        return _error(ERR_INVALID_URL, f"URL invalide : '{img_url}'")

    # --- Téléchargement de l'image ---
    try:
        image_bytes = download_image(img_url)
    except ValueError as exc:
        return _error(ERR_INVALID_URL, str(exc))
    except RuntimeError as exc:
        return _error(ERR_DOWNLOAD_FAILED, str(exc))
    except Exception as exc:
        return _error(ERR_INTERNAL, f"Erreur inattendue lors du téléchargement : {exc}", status=500)

    # --- Analyse de l'image ---
    try:
        ripe_count = count_ripe_tomatoes(image_bytes)
    except RuntimeError as exc:
        return _error(ERR_DECODE_FAILED, str(exc))
    except Exception as exc:
        return _error(ERR_INTERNAL, f"Erreur inattendue lors de l'analyse : {exc}", status=500)

    # --- Insertion Supabase ---
    try:
        insert_tomato_status(
            proc_id=proc_id,
            img_supabase_url=img_url,
            ripe_tomatos=ripe_count,
            supabase_url=supabase_url,
            supabase_key=supabase_key,
        )
    except RuntimeError as exc:
        return _error(ERR_SUPABASE_INSERT, str(exc), status=502)
    except Exception as exc:
        return _error(ERR_INTERNAL, f"Erreur inattendue lors de l'insertion : {exc}", status=500)

    # --- Réponse succès ---
    return {
        "proc_id":          proc_id,
        "img_supabase_url": img_url,
        "ripe_tomatos":     ripe_count,
        "status":           "ok",
    }


# ---------------------------------------------------------------------------
# Point d'entrée local (test sans déploiement)
# ---------------------------------------------------------------------------
@app.local_entrypoint()
def main():
    """
    Test local : appelle l'endpoint avec un payload fictif.
    Utilise : modal run modal/tomato_detector.py
    """
    import json
    from dotenv import load_dotenv

    load_dotenv()  # charge le .env local pour les tests

    test_payload = {
        "proc_id":          "6c9e56c4-ceae-4088-b77b-bb2d034413a0",
        "img_supabase_url": "https://zqiuzulwmfjuajzrztli.supabase.co/storage/v1/object/public/tomato_plantations/test.jpg",
    }

    result = detect_ripe_tomatoes.remote(test_payload)
    print(json.dumps(result, indent=2, ensure_ascii=False))
