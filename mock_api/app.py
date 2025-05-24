# /home/ubuntu/aquachain_mvp/mock_api/app.py
from flask import Flask, jsonify, request
from flask_cors import CORS
import random

app = Flask(__name__)
# Enable CORS for all routes and origins
CORS(app, resources={r"/api/*": {"origins": "*"}})

# --- Mock Data Store ---
# In a real scenario, this would interact with a database or external services

mock_ecosystem_stats = {
    "pollutionLevel": 15,
    "totalPopulation": 123,
    "activeSponsors": 2,
}

mock_user_fishes = {
    "0xUSER1_MOCK_ADDRESS": [
        { "id": "1", "name": "Nemo", "growthStage": 1, "hypeLevel": 150, "health": 90, "owner": "0xUSER1_MOCK_ADDRESS" },
        { "id": "4", "name": "Coral", "growthStage": 0, "hypeLevel": 20, "health": 100, "owner": "0xUSER1_MOCK_ADDRESS" },
    ],
    "0xUSER2_MOCK_ADDRESS": [
        { "id": "2", "name": "Dory", "growthStage": 2, "hypeLevel": 300, "health": 80, "owner": "0xUSER2_MOCK_ADDRESS" },
    ],
    "0xSPONSOR_MOCK_ADDRESS": [
         { "id": "5", "name": "SponsorFish", "growthStage": 0, "hypeLevel": 50, "health": 100, "owner": "0xSPONSOR_MOCK_ADDRESS" },
    ]
    # Add more mock users/fish as needed
}

mock_leaderboard = [
    { "rank": 1, "address": "0x123...abc", "score": 5800 },
    { "rank": 2, "address": "0x456...def", "score": 4500 },
    { "rank": 3, "address": "0x789...ghi", "score": 3200 },
    { "rank": 4, "address": "0xabc...123", "score": 2100 },
    { "rank": 5, "address": "0xdef...456", "score": 1500 },
]

next_fish_id = 6

# --- API Endpoints ---

@app.route("/api/stats", methods=["GET"])
def get_ecosystem_stats():
    """Returns mock ecosystem statistics."""
    # Simulate slight changes over time
    mock_ecosystem_stats["pollutionLevel"] = max(0, mock_ecosystem_stats["pollutionLevel"] + random.randint(-1, 1))
    return jsonify(mock_ecosystem_stats)

@app.route("/api/fishes/<user_address>", methods=["GET"])
def get_user_fishes(user_address):
    """Returns a list of mock fishes for a given user address."""
    fishes = mock_user_fishes.get(user_address, [])
    return jsonify(fishes)

@app.route("/api/leaderboard", methods=["GET"])
def get_leaderboard():
    """Returns the mock leaderboard."""
    return jsonify(mock_leaderboard)

@app.route("/api/simulate/hype", methods=["POST"])
def simulate_hype_increase():
    """Simulates receiving social engagement and returns a mock hype score."""
    # In a real app, this might take engagement data (e.g., tweet ID) as input
    # data = request.json
    # platform = data.get("platform")
    # content_id = data.get("content_id")
    # Here, just return a random hype value
    hype_increase = random.randint(10, 100)
    return jsonify({"hypeIncrease": hype_increase, "message": "Simulated hype generated successfully."})

@app.route("/api/simulate/spawn", methods=["POST"])
def simulate_spawn():
    """Simulates spawning a new fish based on engagement (mock)."""
    global next_fish_id
    user_address = request.json.get("userAddress")
    if not user_address:
        return jsonify({"error": "userAddress is required"}), 400

    new_fish = {
        "id": str(next_fish_id),
        "name": f"NewFish{next_fish_id}",
        "growthStage": 0,
        "hypeLevel": random.randint(0, 50),
        "health": 100,
        "owner": user_address
    }
    next_fish_id += 1

    if user_address not in mock_user_fishes:
        mock_user_fishes[user_address] = []
    mock_user_fishes[user_address].append(new_fish)
    mock_ecosystem_stats["totalPopulation"] += 1

    return jsonify({"message": "Fish spawned successfully (simulated)", "fish": new_fish}), 201

@app.route("/api/simulate/clean", methods=["POST"])
def simulate_clean():
    """Simulates cleaning the ocean (reducing pollution)."""
    cleaning_power = request.json.get("cleaningPower", 10)
    mock_ecosystem_stats["pollutionLevel"] = max(0, mock_ecosystem_stats["pollutionLevel"] - cleaning_power)
    return jsonify({"message": "Ocean cleaned (simulated)", "newPollutionLevel": mock_ecosystem_stats["pollutionLevel"]})


# --- Run the App ---
if __name__ == "__main__":
    # Listen on all interfaces (0.0.0.0) and a common port (e.g., 5001)
    # Use a different port than the Next.js default (3000)
    app.run(host="0.0.0.0", port=5001, debug=True)
