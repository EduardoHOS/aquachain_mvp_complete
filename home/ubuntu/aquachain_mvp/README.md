# Aquachain: Memecoin Ecosystem MVP (Sui Overflow Hackathon 2025)

## 🚀 Project Overview

Aquachain is a memecoin ecosystem built for the Degen track of the Sui Overflow 2025 Hackathon. It simulates a marine life ecosystem where tokens, represented as fish ($FISH), thrive or perish based on social engagement ("hype"). This MVP provides the core smart contracts, an interactive frontend, a mock API for simulation, and documentation to demonstrate the concept.

The ecosystem features:
*   **$FISH Token:** A Sui Move token with standard functions (mint, burn, transfer).
*   **Growth Mechanism:** Fish "grow" (metadata update) based on a simulated "hype index" derived from social engagement.
*   **Survival Mechanic:** Fish can "die" (burn) due to inactivity or ecosystem pollution.
*   **Ecosystem Health:** A shared state object tracks the overall "pollution level" affecting fish.
*   **Interactive Aquarium:** A Next.js frontend visualizes the fish tokens in a dynamic aquarium.
*   **Sponsorship:** A basic interface allows sponsors (mocked) to mint special fish.
*   **Mock API:** Simulates hype generation, social engagement triggers, and provides data for the frontend.

## 📁 Project Structure

```
aquachain_mvp/
├── contracts/            # Sui Move smart contracts
│   └── aquachain_contracts/
│       ├── sources/      # Move source files (fish.move)
│       ├── tests/        # Move test files (fish_tests.move)
│       └── Move.toml     # Package manifest
├── frontend/             # Next.js frontend application
│   ├── public/           # Static assets
│   ├── src/
│   │   ├── app/          # App router pages and layout
│   │   ├── components/   # React components (Aquarium, ActionsPanel, etc.)
│   │   └── config/       # Configuration (constants)
│   ├── next.config.mjs   # Next.js config
│   ├── package.json      # Frontend dependencies
│   └── ...               # Other Next.js files (tsconfig, tailwind.config, etc.)
├── mock_api/             # Flask mock API
│   ├── app.py            # Flask application code
│   └── api.log           # Log file for the running API
├── docs/                 # Documentation (this file)
└── todo.md               # Development checklist
```

## 🛠️ Getting Started

### Prerequisites

*   **Node.js & npm:** Required for the Next.js frontend. (v20+ recommended)
*   **Rust & Cargo:** Required for building Sui Move contracts and installing the Sui CLI. Install via [rustup.rs](https://rustup.rs/).
*   **Sui CLI:** Required for contract deployment and interaction. Follow the [official Sui installation guide](https://docs.sui.io/guides/developer/getting-started/sui-install). Ensure the CLI binary path is added to your system's PATH.
    *   *Note:* This project was developed using the pre-compiled binary for `testnet-v1.49.1` on Ubuntu x86_64 due to compilation time constraints.
*   **Python & pip:** Required for the Flask mock API. (Python 3.10+ recommended)
*   **Sui Wallet Extension:** A Sui-compatible browser wallet (e.g., Sui Wallet, Suiet) is needed to interact with the frontend on the Testnet.

### Installation

1.  **Clone the repository (or extract the provided code).**
2.  **Install Frontend Dependencies:**
    ```bash
    cd aquachain_mvp/frontend
    npm install
    ```
3.  **Install Mock API Dependencies:**
    ```bash
    cd ../mock_api
    pip3 install Flask
    ```

## 🏗️ Build Instructions

1.  **Build Smart Contracts:**
    ```bash
    cd aquachain_mvp/contracts/aquachain_contracts
    # Ensure Sui CLI is in PATH
    sui move build
    ```
    This compiles the Move code and checks for errors.

2.  **Build Frontend:**
    ```bash
    cd ../../frontend
    npm run build
    ```
    This creates an optimized production build of the Next.js application in the `.next` directory.

## ▶️ Running the Application (Development / Demo)

For a local demonstration, run the mock API and the frontend development server:

1.  **Run the Mock API:**
    ```bash
    cd aquachain_mvp/mock_api
    python3 app.py &
    ```
    The API will run in the background on `http://127.0.0.1:5001`.

2.  **Run the Frontend Development Server:**
    ```bash
    cd ../frontend
    npm run dev
    ```
    The frontend will be accessible at `http://localhost:3000`.

3.  **Interact:** Open `http://localhost:3000` in your browser. Connect your Sui wallet (ensure it's set to **Testnet**). Interact with the Aquarium, Stats, Actions, and Sponsor panels.

## 📜 Contract Deployment Guide (Testnet Example)

**IMPORTANT:** The frontend code currently uses placeholder IDs. You **MUST** replace these after deploying your contracts.

1.  **Ensure Sui CLI is configured for Testnet:**
    ```bash
    sui client switch --env testnet
    sui client active-address # Note your address
    sui client gas            # Get some Testnet SUI if needed
    ```

2.  **Publish the Contract:**
    ```bash
    cd aquachain_mvp/contracts/aquachain_contracts
    sui client publish --gas-budget 50000000 # Adjust gas budget if needed
    ```

3.  **Identify Object IDs:** The publish command output will list the created objects. You need to find:
    *   **Package ID:** The main ID for your published package.
    *   **EcosystemState Object ID:** The ID of the shared `EcosystemState` object.
    *   **AquachainTreasuryCap Object ID:** The ID of the `AquachainTreasuryCap` object (transferred to the publisher address).

4.  **Update Frontend Constants:** Open `aquachain_mvp/frontend/src/config/constants.ts` and replace the placeholder values for `PACKAGE_ID`, `ECOSYSTEM_STATE_ID`, and `TREASURY_CAP_ID` with the actual IDs obtained from the deployment.

5.  **Rebuild/Redeploy Frontend:** If you updated the constants, rebuild the frontend (`npm run build`) and redeploy if necessary, or restart the dev server (`npm run dev`).

6.  **Contract Interaction:** The frontend uses `@mysten/dapp-kit` and placeholders for transaction building. Review the `handleSpawnFish`, `handleCleanOcean`, and `handleSponsorMint` functions in the respective components (`ActionsPanel.tsx`, `SponsorInterface.tsx`) and uncomment/adapt the `txb.moveCall` sections with the correct function signatures and arguments based on your deployed `PACKAGE_ID` and object IDs.

## 🔌 Mock API Endpoints

The mock API runs on `http://127.0.0.1:5001`.

*   `GET /api/stats`: Returns mock ecosystem statistics (pollution, population, sponsors).
*   `GET /api/fishes/<user_address>`: Returns a list of mock fishes for the specified address.
*   `GET /api/leaderboard`: Returns a mock leaderboard.
*   `POST /api/simulate/hype`: Simulates receiving social engagement, returns a mock hype score.
*   `POST /api/simulate/spawn`: Simulates spawning a new fish for a user (requires `{"userAddress": "..."}` in body).
*   `POST /api/simulate/clean`: Simulates cleaning the ocean (reduces pollution level, takes optional `{"cleaningPower": ...}` in body).

## 📈 Business Model Integration Notes

The current MVP codebase provides foundational elements for potential business models:

*   **Token Staking:** The `FishMetadata` object holds the `Coin<FISH>`. Staking mechanics would involve creating separate contracts or functions to lock these metadata objects and distribute rewards.
*   **Sponsorship:** The `SponsorInterface.tsx` component and `register_sponsor`/`sponsor_mint_fish` contract functions provide a basic framework. Real payment processing (e.g., accepting SUI) would need to be added to the `register_sponsor` flow or a separate sponsorship tier system.
*   **Gamified Donations:** The `clean_ocean` function could be adapted to require burning $FISH or donating SUI, creating a gamified donation system for ecosystem health.
*   **New Species Creation:** The `evolve_fish` function is a placeholder. A more robust system could allow sponsors or users (potentially via payment) to trigger the creation of entirely new token types (e.g., $WHALE, $CRAB) using a factory pattern in the smart contracts, extending the ecosystem.

## 🛣️ Future Enhancements & Roadmap

*   **Real API Integration:** Replace the mock API with real services that track social media engagement (Twitter API, Farcaster Hubs, etc.) to generate the hype index.
*   **Full Contract Integration:** Remove placeholder comments in the frontend and implement actual transaction signing/execution for all actions (spawn, clean, sponsor mint, evolve).
*   **Improved Aquarium:** Enhance visuals with more diverse fish types, background elements, and smoother animations (e.g., using libraries like PixiJS or Three.js if complexity increases).
*   **Refined Tokenomics:** Develop more sophisticated logic for hype decay, health mechanics, pollution effects, and growth/evolution triggers.
*   **Staking & Rewards:** Implement staking contracts and reward distribution mechanisms.
*   **UI/UX Polish:** Improve overall user interface design, add more feedback mechanisms, and enhance responsiveness.
*   **NFT Representation:** Consider representing each `FishMetadata` object as an NFT with dynamic traits based on its state.
*   **Admin Controls:** Implement proper admin roles for managing sponsors and ecosystem parameters.


