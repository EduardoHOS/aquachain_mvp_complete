// /home/ubuntu/aquachain_mvp/frontend/src/app/page.tsx
"use client";

import { ConnectButton } from "@mysten/dapp-kit";
import Aquarium from "../components/Aquarium";
import StatsDisplay from "../components/StatsDisplay";
import ActionsPanel from "../components/ActionsPanel";
import Leaderboard from "../components/Leaderboard";
import SponsorInterface from "../components/SponsorInterface";

export default function Home() {
	return (
		<div className="flex flex-col min-h-screen">
			<header className="flex justify-between items-center p-4 bg-blue-900 shadow-md">
				<h1 className="text-3xl font-bold text-cyan-300">Aquachain</h1>
				<ConnectButton />
			</header>

			<div className="flex flex-grow mt-4 gap-4">
				{/* Main Aquarium View */}
				<div className="w-3/4 bg-blue-800 rounded-lg shadow-lg p-4 border-2 border-cyan-500 relative overflow-hidden">
					<Aquarium />
				</div>

				{/* Sidebar with Stats and Actions */}
				<div className="w-1/4 flex flex-col gap-4">
					<div className="bg-blue-800 rounded-lg shadow-lg p-4 border border-cyan-600">
						<StatsDisplay />
					</div>
					<div className="bg-blue-800 rounded-lg shadow-lg p-4 border border-cyan-600">
						<ActionsPanel />
					</div>
					<div className="bg-blue-800 rounded-lg shadow-lg p-4 border border-cyan-600">
						<SponsorInterface />
					</div>
				</div>
			</div>

			{/* Leaderboard Section */}
			<div className="mt-4 bg-blue-800 rounded-lg shadow-lg p-4 border border-cyan-600">
				<Leaderboard />
			</div>
		</div>
	);
}

