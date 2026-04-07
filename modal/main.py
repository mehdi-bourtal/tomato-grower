# app.py
import modal
from datetime import datetime, timedelta, timezone
import os

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
- Temperature: {weather_temperature}°C
- Humidity: {weather_humidity}%
- Precipitation: {weather_precipitation}mm
- Cloud cover: {weather_cloud_cover}%
- Description: {weather_description}

## Tomato ripeness prediction:
{ripeness_prediction}

Based on all this data, provide a detailed action plan in JSON format with the following structure:
{{
    "ripeness_alert": true,
    "water_needed": false,
    "fertilizer_needed": false,
    "action_plan": "detailed recommendations",
    "alerts": ["list of urgent alerts if any"]
}}
"""


def fetch_weather(lat: float, lon: float) -> dict:
    import requests

    openweather_key = os.environ["OPENWEATHER_API_KEY"]
    resp = requests.get(
        "https://api.openweathermap.org/data/2.5/weather",
        params={
            "lat": lat,
            "lon": lon,
            "appid": openweather_key,
            "units": "metric",
            "lang": "en",
        },
        timeout=20,
    )
    resp.raise_for_status()

    data = resp.json()
    return {
        "temperature": data["main"]["temp"],
        "humidity": data["main"]["humidity"],
        "precipitation": data.get("rain", {}).get("1h", 0),
        "cloud_cover": data["clouds"]["all"],
        "description": data["weather"][0]["description"],
    }


def predict_ripeness(sensor_data: dict, historical_data: list) -> str:
    return "Model not yet integrated"


def save_to_supabase(data: dict, headers: dict, supabase_url: str) -> dict:
    import requests

    payload = data.copy()

    # Si proc_id absent, on crée une ligne dans proc_info pour générer/initialiser l'appareil
    if not payload.get("proc_id"):
        resp = requests.post(
            f"{supabase_url}/rest/v1/proc_info",
            headers={**headers, "Prefer": "return=representation"},
            json={},
            timeout=20,
        )
        resp.raise_for_status()
        rows = resp.json()
        payload["proc_id"] = rows[0]["proc_id"]

    payload["date"] = datetime.now(timezone.utc).isoformat()

    resp = requests.post(
        f"{supabase_url}/rest/v1/culture_info",
        headers={**headers, "Prefer": "return=minimal"},
        json=payload,
        timeout=20,
    )
    resp.raise_for_status()

    return payload


def fetch_historical_data(proc_id: str, headers: dict, supabase_url: str) -> list:
    import requests

    since = (datetime.now(timezone.utc) - timedelta(hours=24)).isoformat()

    resp = requests.get(
        f"{supabase_url}/rest/v1/culture_info",
        headers=headers,
        params={
            "proc_id": f"eq.{proc_id}",
            "date": f"gte.{since}",
            "order": "date.desc",
        },
        timeout=20,
    )
    resp.raise_for_status()
    return resp.json()


def fetch_location(proc_id: str, headers: dict, supabase_url: str):
    import requests

    resp = requests.get(
        f"{supabase_url}/rest/v1/proc_info",
        headers=headers,
        params={
            "proc_id": f"eq.{proc_id}",
            "limit": 1,
        },
        timeout=20,
    )
    resp.raise_for_status()
    data = resp.json()

    if not data:
        requests.post(
            f"{supabase_url}/rest/v1/proc_info",
            headers={**headers, "Prefer": "return=minimal"},
            json={"proc_id": proc_id},
            timeout=20,
        ).raise_for_status()
        return None, None

    lat = data[0].get("latitude")
    lon = data[0].get("longitude")

    if lat is None or lon is None:
        return None, None

    return float(lat), float(lon)


def call_gemini(prompt: str, gemini_key: str) -> dict:
    import requests
    import json

    response = requests.post(
        f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={gemini_key}",
        headers={"Content-Type": "application/json"},
        json={
            "contents": [{"parts": [{"text": prompt}]}],
        },
        timeout=30,
    )

    response.raise_for_status()
    gemini_data = response.json()

    if "candidates" not in gemini_data:
        return {
            "error": "Gemini response missing 'candidates'",
            "gemini_raw": gemini_data,
        }

    raw_answer = gemini_data["candidates"][0]["content"]["parts"][0]["text"]

    try:
        cleaned = raw_answer.strip().removeprefix("```json").removesuffix("```").strip()
        return json.loads(cleaned)
    except json.JSONDecodeError:
        return {"raw": raw_answer}


@app.function(
    image=image,
    secrets=[modal.Secret.from_name("my-secrets")],
)
@modal.fastapi_endpoint(method="POST")
def run_pipeline(payload: dict) -> dict:
    import json

    supabase_url = os.environ["SUPABASE_URL"]
    supabase_key = os.environ["SUPABASE_KEY"]
    gemini_key = os.environ["GEMINI_API_KEY"]

    supabase_headers = {
        "apikey": supabase_key,
        "Authorization": f"Bearer {supabase_key}",
        "Content-Type": "application/json",
    }

    try:
        # 1. Sauvegarde et récupère le payload final avec proc_id garanti
        saved_payload = save_to_supabase(payload, supabase_headers, supabase_url)
        proc_id = saved_payload["proc_id"]

        # 2. Coordonnées GPS
        lat, lon = fetch_location(proc_id, supabase_headers, supabase_url)

        # 3. Historique 24h pour CE proc_id
        historical_data = fetch_historical_data(proc_id, supabase_headers, supabase_url)
        ripeness_prediction = predict_ripeness(saved_payload, historical_data)

        # 4. Météo
        if lat is not None and lon is not None:
            weather_data = fetch_weather(lat, lon)
        else:
            weather_data = {
                "temperature": "unknown",
                "humidity": "unknown",
                "precipitation": 0,
                "cloud_cover": "unknown",
                "description": "No location available yet",
            }

        # 5. Prompt + appel Gemini
        prompt = DEFAULT_PROMPT.format(
            temperature=saved_payload.get("temperature"),
            humidity_int=saved_payload.get("humidity_int"),
            humidity_ext=saved_payload.get("humidity_ext"),
            luminosity=saved_payload.get("luminosity"),
            historical_data=json.dumps(historical_data, indent=2),
            weather_temperature=weather_data["temperature"],
            weather_humidity=weather_data["humidity"],
            weather_precipitation=weather_data["precipitation"],
            weather_cloud_cover=weather_data["cloud_cover"],
            weather_description=weather_data["description"],
            ripeness_prediction=ripeness_prediction,
        )

        answer = call_gemini(prompt, gemini_key)

        return {
            "proc_id": proc_id,
            "result": answer,
        }

    except Exception as e:
        return {"error": str(e)}