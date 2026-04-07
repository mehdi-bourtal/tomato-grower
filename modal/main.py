# app.py
import modal
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv
import os

# Charge le .env uniquement en local
load_dotenv()

app = modal.App("tomato-grower-app")

image = modal.Image.debian_slim().pip_install(
    "requests",
    "fastapi[standard]",
    "python-dotenv",
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
- Temperature: {weather_temperature}°C
- Humidity: {weather_humidity}%
- Precipitation: {weather_precipitation}mm
- Cloud cover: {weather_cloud_cover}%
- Description: {weather_description}

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
    import requests
    openweather_key = os.getenv("OPENWEATHER_API_KEY")
    resp = requests.get(
        "https://api.openweathermap.org/data/2.5/weather",
        params={
            "lat": lat,
            "lon": lon,
            "appid": openweather_key,
            "units": "metric",
            "lang": "en",
        },
    )
    data = resp.json()
    return {
        "temperature": data["main"]["temp"],
        "humidity": data["main"]["humidity"],
        "precipitation": data.get("rain", {}).get("1h", 0),
        "cloud_cover": data["clouds"]["all"],
        "description": data["weather"][0]["description"],
    }


def predict_ripeness(sensor_data: dict, historical_data: list) -> str:
    # TODO: intégrer ton vrai modèle ML ici
    return "Model not yet integrated"


def save_to_supabase(data: dict, headers: dict, supabase_url: str):
    import requests

    # Si proc_id absent, on crée une ligne vide pour générer un UUID
    if not data.get("proc_id"):
        resp = requests.post(
            f"{supabase_url}/rest/v1/culture_info",
            headers={**headers, "Prefer": "return=representation"},
            json={},
        )
        generated_id = resp.json()[0]["proc_id"]
        data["proc_id"] = generated_id

    data["created_at"] = datetime.now(timezone.utc).isoformat()
    requests.post(
        f"{supabase_url}/rest/v1/culture_info",
        headers={**headers, "Prefer": "return=minimal"},
        json=data,
    )


def fetch_historical_data(headers: dict, supabase_url: str) -> list:
    import requests
    since = (datetime.now(timezone.utc) - timedelta(hours=24)).isoformat()
    resp = requests.get(
        f"{supabase_url}/rest/v1/culture_info?created_at=gte.{since}&order=created_at.desc",
        headers=headers,
    )
    return resp.json()


def fetch_location(proc_id: str, headers: dict, supabase_url: str) -> tuple:
    import requests

    resp = requests.get(
        f"{supabase_url}/rest/v1/proc_info?proc_id=eq.{proc_id}&limit=1",
        headers=headers,
    )
    data = resp.json()

    if not data:
        raise ValueError(f"proc_id '{proc_id}' not found in proc_infos table")

    lat = float(data[0]["latitude"])
    lon = float(data[0]["longitude"])
    return lat, lon


@app.function(
    image=image,
    secrets=[modal.Secret.from_name("my-secrets")],
)
@modal.fastapi_endpoint(method="POST")
def run_pipeline(payload: dict) -> dict:
    import requests, json

    supabase_url = os.getenv("SUPABASE_URL")
    supabase_key = os.getenv("SUPABASE_KEY")
    gemini_key = os.getenv("GEMINI_API_KEY")

    supabase_headers = {
        "apikey": supabase_key,
        "Authorization": f"Bearer {supabase_key}",
        "Content-Type": "application/json",
    }

    # 1. Sauvegarde les nouvelles données capteurs
    save_to_supabase(payload.copy(), supabase_headers, supabase_url)

    # 2. Récupère les coordonnées GPS depuis proc_infos
    try:
        lat, lon = fetch_location(payload["proc_id"], supabase_headers, supabase_url)
    except (ValueError, KeyError) as e:
        return {"error": str(e)}

    # 3. Historique 24h + prédiction maturité
    historical_data = fetch_historical_data(supabase_headers, supabase_url)
    ripeness_prediction = predict_ripeness(payload, historical_data)

    # 4. Météo via OpenWeatherMap
    weather_data = fetch_weather(lat, lon)

    # 5. Prompt + appel Gemini
    prompt = DEFAULT_PROMPT.format(
        temperature=payload["temperature"],
        humidity_int=payload["humidity_int"],
        humidity_ext=payload["humidity_ext"],
        luminosity=payload["luminosity"],
        historical_data=json.dumps(historical_data, indent=2),
        weather_temperature=weather_data["temperature"],
        weather_humidity=weather_data["humidity"],
        weather_precipitation=weather_data["precipitation"],
        weather_cloud_cover=weather_data["cloud_cover"],
        weather_description=weather_data["description"],
        ripeness_prediction=ripeness_prediction,
    )

    response = requests.post(
        f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={gemini_key}",
        headers={"Content-Type": "application/json"},
        json={
            "contents": [{"parts": [{"text": prompt}]}],
        },
    )
    raw_answer = response.json()["candidates"][0]["content"]["parts"][0]["text"]

    # 6. Parse le JSON retourné par Gemini
    try:
        cleaned = raw_answer.strip().removeprefix("```json").removesuffix("```").strip()
        answer = json.loads(cleaned)
    except json.JSONDecodeError:
        answer = {"raw": raw_answer}

    return answer

@app.local_entrypoint()
def main():
    test_payload = {
        "proc_id": "4eaz-yhe09-IOL9U7",
        "temperature": 20,
        "humidity_int": 55,
        "humidity_ext": 67,
        "luminosity": 6600,
    }
    import json
    result = run_pipeline.remote(test_payload)
    print(json.dumps(result, indent=2))

