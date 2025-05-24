// /home/ubuntu/aquachain_mvp/frontend/src/components/Leaderboard.tsx
"use client";

import React, { useState, useEffect } from 'react';
import { MOCK_API_URL } from '../config/constants';

interface LeaderboardEntry {
  rank: number;
  address: string;
  score: number; // Could represent total hype, fish count, etc.
}

const Leaderboard: React.FC = () => {
  const [leaders, setLeaders] = useState<LeaderboardEntry[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchLeaderboard = async () => {
      setIsLoading(true);
      setError(null);
      try {
        const response = await fetch(`${MOCK_API_URL}/leaderboard`);
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data: LeaderboardEntry[] = await response.json();
        setLeaders(data);
      } catch (e) {
        console.error("Failed to fetch leaderboard:", e);
        setError("Could not load leaderboard data.");
        setLeaders([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchLeaderboard();
    // Optional: Refresh leaderboard periodically
    const intervalId = setInterval(fetchLeaderboard, 30000); // Refresh every 30 seconds

    return () => clearInterval(intervalId);
  }, []);

  return (
    <div className="text-cyan-200">
      <h2 className="text-xl font-semibold mb-3 text-cyan-100 border-b border-cyan-700 pb-1">Leaderboard</h2>
      {isLoading && leaders.length === 0 && <p>Loading leaderboard...</p>} {/* Show loading only initially */}
      {error && <p className="text-red-400">{error}</p>}
      {!isLoading && !error && leaders.length === 0 && <p>Leaderboard is empty.</p>}
      {leaders.length > 0 && (
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-left min-w-[400px]">
            <thead className="text-xs text-cyan-300 uppercase bg-blue-700">
              <tr>
                <th scope="col" className="px-4 py-2">Rank</th>
                <th scope="col" className="px-4 py-2">Address</th>
                <th scope="col" className="px-4 py-2">Score</th>
              </tr>
            </thead>
            <tbody>
              {leaders.map((leader) => (
                <tr key={leader.rank} className="border-b border-blue-700 hover:bg-blue-700">
                  <td className="px-4 py-2 font-medium">{leader.rank}</td>
                  <td className="px-4 py-2 truncate max-w-xs" title={leader.address}>{leader.address}</td>
                  <td className="px-4 py-2">{leader.score}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default Leaderboard;

