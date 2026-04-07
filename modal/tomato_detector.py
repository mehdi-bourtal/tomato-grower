"""
tomato_detector.py
==================
Endpoint Modal : reçoit une image JPEG binaire d'un ESP32 OV2640,
la stocke dans Supabase Storage, détecte les tomates mûres par
analyse de contours rouges (OpenCV), puis insère un bilan dans `tomatos_status`.

Déploiement :
    modal deploy tomato_detector.py       (depuis le dossier modal/)

Variables requises dans le secret Modal "my-secrets" :
    SUPABASE_URL          – URL REST Supabase  (ex: https://xxx.supabase.co)
    SUPABASE_SERVICE_KEY  – clé service Supabase (rôle service_role)
    SUPABASE_BUCKET       – nom du bucket Storage  (ex: tomato_plantations)

Appel HTTP depuis l'ESP32 (multipart/form-data) :
    POST <endpoint_url>
    Content-Type: multipart/form-data
    Champs :
        proc_id  – <uuid>      (champ texte)
        image    – <bytes>     (fichier binaire JPEG)
"""

import modal
import os
from datetime import datetime, timezone
from typing import Any

# ---------------------------------------------------------------------------
# Image Docker – dépendances Python installées au build
# ---------------------------------------------------------------------------
docker_image = (
    modal.Image.debian_slim()
    # Bibliothèques système requises par OpenCV headless
    .apt_install("libglib2.0-0", "libgl1")
    .pip_install(
        "requests",
        "numpy",
        "opencv-python-headless",  # OpenCV sans GUI
        "fastapi[standard]",
        "python-multipart",        # parsing multipart/form-data dans FastAPI
        "python-dotenv",
    )
)

app = modal.App("tomato-detector")

# ---------------------------------------------------------------------------
# Codes d'erreur métier renvoyés en JSON
# ---------------------------------------------------------------------------
ERR_MISSING_PARAM    = "MISSING_PARAMETER"
ERR_EMPTY_IMAGE      = "EMPTY_IMAGE"
ERR_DECODE_FAILED    = "IMAGE_DECODE_FAILED"
ERR_STORAGE_UPLOAD   = "STORAGE_UPLOAD_FAILED"
ERR_SUPABASE_INSERT  = "SUPABASE_INSERT_FAILED"
ERR_INTERNAL         = "INTERNAL_ERROR"


def _error(code: str, detail: str, status: int = 400) -> dict:
    """Construit une réponse d'erreur normalisée."""
    return {"error": code, "detail": detail, "status": status}


# ---------------------------------------------------------------------------
# Étape 1 – Upload vers Supabase Storage
# ---------------------------------------------------------------------------
def upload_to_supabase_storage(
    image_bytes: bytes,
    proc_id: str,
    supabase_url: str,
    supabase_key: str,
    bucket: str,
) -> str:
    """
    Uploade les octets JPEG dans le bucket Supabase Storage.

    Le chemin dans le bucket est : {proc_id}/{timestamp_iso}.jpg
    Le header "x-upsert: true" permet d'écraser si le fichier existe déjà.

    Returns:
        URL publique de l'image dans le bucket Supabase.

    Raises:
        RuntimeError – si l'upload échoue (code HTTP inattendu).
    """
    import requests

    # Chemin unique dans le bucket, organisé par proc_id
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    storage_path = f"{proc_id}/{timestamp}.jpg"

    upload_url = f"{supabase_url}/storage/v1/object/{bucket}/{storage_path}"

    headers = {
        "Authorization": f"Bearer {supabase_key}",
        "Content-Type":  "image/jpeg",
        "x-upsert":      "true",   # écrase si le fichier existe déjà
    }

    resp = requests.post(upload_url, headers=headers, data=image_bytes, timeout=30)

    # Supabase Storage renvoie 200 ou 201 selon la version
    if resp.status_code not in (200, 201):
        raise RuntimeError(
            f"Upload Storage échoué ({resp.status_code}) : {resp.text}"
        )

    # Construction de l'URL publique du fichier uploadé
    public_url = (
        f"{supabase_url}/storage/v1/object/public/{bucket}/{storage_path}"
    )
    return public_url


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

    # Décodage de l'image depuis ses octets bruts
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if img is None:
        raise RuntimeError(
            "Impossible de décoder l'image "
            "(format non supporté ou fichier corrompu)."
        )

    # Conversion BGR → HSV (plus robuste pour la détection de couleur)
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # Plages HSV pour le rouge (le rouge est cyclique en HSV → 2 intervalles)
    lower_red1 = np.array([0,   80,  60])
    upper_red1 = np.array([10, 255, 255])
    lower_red2 = np.array([160, 80,  60])
    upper_red2 = np.array([180, 255, 255])

    mask1 = cv2.inRange(hsv, lower_red1, upper_red1)
    mask2 = cv2.inRange(hsv, lower_red2, upper_red2)
    red_mask = cv2.bitwise_or(mask1, mask2)

    # Fermeture morphologique : bouche les trous, supprime le bruit
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9))
    red_mask = cv2.morphologyEx(red_mask, cv2.MORPH_CLOSE, kernel, iterations=2)
    red_mask = cv2.morphologyEx(red_mask, cv2.MORPH_OPEN,  kernel, iterations=1)

    # Détection des contours fermés sur le masque binaire
    contours, _ = cv2.findContours(
        red_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
    )

    # Seuil minimal de surface (calibré pour OV2640 ~640×480 px)
    MIN_AREA = 300

    ripe_count = 0
    for cnt in contours:
        area = cv2.contourArea(cnt)
        if area < MIN_AREA:
            continue  # trop petit → bruit, ignoré

        # Circularité = 4π·A / P²  (1.0 = cercle parfait)
        perimeter = cv2.arcLength(cnt, True)
        if perimeter == 0:
            continue
        circularity = 4 * 3.14159 * area / (perimeter ** 2)

        # Accepte les formes suffisamment rondes (seuil ≥ 0.45)
        if circularity >= 0.45:
            ripe_count += 1

    return ripe_count


# ---------------------------------------------------------------------------
# Étape 3 – Insertion dans Supabase DB
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
        RuntimeError – si l'insertion échoue (code HTTP inattendu).
    """
    import requests

    headers = {
        "apikey":        supabase_key,
        "Authorization": f"Bearer {supabase_key}",
        "Content-Type":  "application/json",
        "Prefer":        "return=minimal",
    }

    row = {
        "proc_id":          proc_id,
        "img_supabase_url": img_supabase_url,
        "ripe_tomtatos":    ripe_tomatos,           # typo intentionnel du schéma
        "date":             datetime.now(timezone.utc).isoformat(),
    }

    resp = requests.post(
        f"{supabase_url}/rest/v1/tomatos_status",
        headers=headers,
        json=row,
        timeout=10,
    )

    if resp.status_code not in (200, 201):
        raise RuntimeError(
            f"Supabase DB a répondu {resp.status_code} : {resp.text}"
        )


# ---------------------------------------------------------------------------
# Endpoint Modal – multipart/form-data
# ---------------------------------------------------------------------------
@app.function(
    image=docker_image,
    secrets=[modal.Secret.from_name("my-secrets")],
    timeout=120,   # généreux pour l'upload + analyse
)
@modal.fastapi_endpoint(method="POST")
async def detect_ripe_tomatoes(request: Any) -> dict:
    """
    Endpoint POST multipart/form-data.

    Champs attendus :
        proc_id  (str)   – UUID du processeur (champ texte)
        image    (bytes) – image JPEG brute envoyée par l'ESP32 OV2640

    Pipeline :
        1. Lecture du form + fichier binaire
        2. Upload du JPEG dans Supabase Storage
        3. Détection des tomates mûres (OpenCV)
        4. Insertion dans tomatos_status (Supabase DB)

    Retourne :
        { "proc_id", "img_supabase_url", "ripe_tomatos", "status": "ok" }
        ou { "error": "CODE", "detail": "...", "status": <int> }
    """
    # --- Récupération des credentials depuis les secrets Modal ---
    supabase_url = os.getenv("SUPABASE_URL")
    supabase_key = os.getenv("SUPABASE_SERVICE_KEY")
    bucket       = os.getenv("SUPABASE_BUCKET")

    if not supabase_url or not supabase_key or not bucket:
        return _error(
            ERR_INTERNAL,
            "Secret(s) manquant(s) : vérifier SUPABASE_URL, "
            "SUPABASE_SERVICE_KEY et SUPABASE_BUCKET dans 'my-secrets'.",
            status=500,
        )

    # --- Lecture du multipart/form-data ---
    try:
        form = await request.form()
    except Exception as exc:
        return _error(
            ERR_INTERNAL,
            f"Impossible de parser le formulaire multipart : {exc}",
            status=400,
        )

    # Champ texte proc_id
    proc_id = (form.get("proc_id") or "").strip()
    if not proc_id:
        return _error(
            ERR_MISSING_PARAM,
            "Le champ 'proc_id' est requis dans le formulaire.",
        )

    # Fichier binaire image
    image_field = form.get("image")
    if image_field is None:
        return _error(
            ERR_MISSING_PARAM,
            "Le champ 'image' (fichier JPEG) est requis dans le formulaire.",
        )

    try:
        image_bytes = await image_field.read()
    except Exception as exc:
        return _error(
            ERR_INTERNAL,
            f"Impossible de lire le fichier image : {exc}",
            status=400,
        )

    if not image_bytes:
        return _error(ERR_EMPTY_IMAGE, "Le fichier image reçu est vide.")

    # --- Upload dans Supabase Storage ---
    try:
        public_url = upload_to_supabase_storage(
            image_bytes=image_bytes,
            proc_id=proc_id,
            supabase_url=supabase_url,
            supabase_key=supabase_key,
            bucket=bucket,
        )
    except RuntimeError as exc:
        return _error(ERR_STORAGE_UPLOAD, str(exc), status=502)
    except Exception as exc:
        return _error(
            ERR_INTERNAL,
            f"Erreur inattendue lors de l'upload Storage : {exc}",
            status=500,
        )

    # --- Détection des tomates mûres ---
    try:
        ripe_count = count_ripe_tomatoes(image_bytes)
    except RuntimeError as exc:
        return _error(ERR_DECODE_FAILED, str(exc))
    except Exception as exc:
        return _error(
            ERR_INTERNAL,
            f"Erreur inattendue lors de l'analyse OpenCV : {exc}",
            status=500,
        )

    # --- Insertion dans la base Supabase ---
    try:
        insert_tomato_status(
            proc_id=proc_id,
            img_supabase_url=public_url,
            ripe_tomatos=ripe_count,
            supabase_url=supabase_url,
            supabase_key=supabase_key,
        )
    except RuntimeError as exc:
        return _error(ERR_SUPABASE_INSERT, str(exc), status=502)
    except Exception as exc:
        return _error(
            ERR_INTERNAL,
            f"Erreur inattendue lors de l'insertion DB : {exc}",
            status=500,
        )

    # --- Réponse succès ---
    return {
        "proc_id":          proc_id,
        "img_supabase_url": public_url,
        "ripe_tomatos":     ripe_count,
        "status":           "ok",
    }


# ---------------------------------------------------------------------------
# Point d'entrée local – test sans déploiement
# ---------------------------------------------------------------------------
@app.local_entrypoint()
def main():
    """
    Test local avec une image JPEG lue depuis le disque.
    Utilise : modal run tomato_detector.py

    Remplacer TEST_IMAGE_PATH et TEST_PROC_ID avant d'exécuter.
    """
    import json
    from dotenv import load_dotenv

    load_dotenv(dotenv_path="../app/.env")  # charge les variables locales

    TEST_IMAGE_PATH = "./test_tomato.jpg"   # image JPEG locale pour le test
    TEST_PROC_ID    = "6c9e56c4-ceae-4088-b77b-bb2d034413a0"

    if not os.path.exists(TEST_IMAGE_PATH):
        print(f"[ERREUR] Image de test introuvable : {TEST_IMAGE_PATH}")
        print("Placer une image JPEG dans modal/test_tomato.jpg pour tester.")
        return

    with open(TEST_IMAGE_PATH, "rb") as f:
        image_bytes = f.read()

    print(f"Image lue : {len(image_bytes)} octets")

    # Simulation d'un appel distant en passant les bytes directement
    # (le vrai endpoint reçoit les bytes via multipart/form-data)
    result = detect_ripe_tomatoes.remote(
        # On simule la requête via un dict pour le test local.
        # En production, l'ESP32 envoie un vrai POST multipart.
        {"_test_proc_id": TEST_PROC_ID, "_test_image": image_bytes}
    )
    print(json.dumps(result, indent=2, ensure_ascii=False))
