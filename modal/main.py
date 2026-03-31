<<<<<<< HEAD
=======
# app.py
import modal
from datetime import datetime, timedelta, timezone

app = modal.App("tomato-grower-app")

image = modal.Image.debian_slim().pip_install(
    "requests",
    "fastapi[standard]",
)

DEFAULT_PROMPT = """
You are an expert in tomato cultivation with deep knowledge in agronomy, plant biology, and precision farming.

## Current sensor data (just received):
- Temperature: {temperature}°C
- Internal humidity: {humidity_int}%
- External humidity: {humidity_ext}%
- Luminosity: {luminosity} lux

## Historical sensor data (last 24h):
{historical_data}

## Current weather conditions:
{weather_data}

## Tomato ripeness prediction:
{ripeness_prediction}

Based on all this data, provide a detailed action plan in JSON format with the following structure:
{{
    "ripeness_alert": true/false,
    "water_needed": true/false,
    "fertilizer_needed": true/false,
    "action_plan": "detailed recommendations",
    "alerts": ["list of urgent alerts if any"]
}}
"""

def fetch_weather(lat: float, lon: float) -> dict:
    """Fetch current weather from Open-Meteo (gratuit, pas de clé requise)"""
    import requests
    resp = requests.get(
        "https://api.open-meteo.com/v1/forecast",
        params={
            "latitude": lat,
            "longitude": lon,
            "current": "temperature_2m,relative_humidity_2m,precipitation,cloud_cover",
        },
    )
    return resp.json().get("current", {})


def predict_model(sensor_data: dict, historical_data: list) -> str:
    # TODO: Intégration de mon modèle prédictif
    return "Model not yet integrated"


def save_to_supabase(data: dict, headers: dict, supabase_url: str):
    """Enregistre les nouvelles données capteurs dans Supabase"""
    import requests
    # Si proc_id est absent ou vide, on crée une ligne vide pour générer un ID
    if not data.get("proc_id"):
        resp = requests.post(
            f"{supabase_url}/rest/v1/sensor_data",
            headers={**headers, "Prefer": "return=representation"},
            json={},  # ligne vide → Supabase génère un UUID automatiquement
        )
        generated_id = resp.json()[0]["proc_id"]
        data["proc_id"] = generated_id   
    
    
    data["created_at"] = datetime.now(timezone.utc).isoformat()
    requests.post(
        f"{supabase_url}/rest/v1/sensor_data",
        headers={**headers, "Prefer": "return=minimal"},
        json=data,
    )


def fetch_historical_data(headers: dict, supabase_url: str) -> list:
    """Récupère les données des dernières 24h depuis Supabase"""
    import requests
    since = (datetime.now(timezone.utc) - timedelta(hours=24)).isoformat()
    resp = requests.get(
        f"{supabase_url}/rest/v1/sensor_data?created_at=gte.{since}&order=created_at.desc",
        headers=headers,
    )
    return resp.json()


@app.function(
    image=image,
    secrets=[modal.Secret.from_name("my-secrets")],
)
@modal.web_endpoint(method="POST")
def run_pipeline(payload: dict) -> dict:
    import os, requests, json

    # 0. Récupération des variables d'environnement
    supabase_url = os.environ["https://zqiuzulwmfjuajzrztli.supabase.co"]
    supabase_key = os.environ["sb_publishable_tfcXW2JkoCww-uLBRYHQdw_UYabR47w"]
    anthropic_key = os.environ["Key"]
    lat = float(os.environ.get("LOCATION_LAT", "48.8566"))  # Paris par défaut
    lon = float(os.environ.get("LOCATION_LON", "2.3522"))

    supabase_headers = {
        "apikey": supabase_key,
        "Authorization": f"Bearer {supabase_key}",
        "Content-Type": "application/json",
    }

    # 1. Enregistre les nouvelles données en Supabase
    save_to_supabase(payload.copy(), supabase_headers, supabase_url)

    # 2. Modèle prédictif (détection tomates mûres)
    historical_data = fetch_historical_data(supabase_headers, supabase_url)
    ripeness_prediction = predict_model(payload, historical_data)

    # 3. Fetch météo
    weather_data = fetch_weather(lat, lon)

    # 4. Construction du prompt et appel Claude
    prompt = DEFAULT_PROMPT.format(
        temperature=payload["temperature"],
        humidity_int=payload["humidity_int"],
        humidity_ext=payload["humidity_ext"],
        luminosity=payload["luminosity"],
        historical_data=json.dumps(historical_data, indent=2),
        weather_data=json.dumps(weather_data, indent=2),
        ripeness_prediction=ripeness_prediction,
    )

    response = requests.post(
        "https://api.anthropic.com/v1/messages",
        headers={
            "x-api-key": anthropic_key,
            "anthropic-version": "2023-06-01",
            "content-type": "application/json",
        },
        json={
            "model": "claude-opus-4-5",
            "max_tokens": 1024,
            "messages": [{"role": "user", "content": prompt}],
        },
    )

    raw_answer = response.json()["content"][0]["text"]

    # 5. Parse le JSON retourné par Claude
    try:
        answer = json.loads(raw_answer)
    except json.JSONDecodeError:
        answer = {"raw": raw_answer}

    return answer
>>>>>>> 6bbdd32 (Modification)
