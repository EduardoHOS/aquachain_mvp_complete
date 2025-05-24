// /home/ubuntu/aquachain_mvp/frontend/src/components/StatsDisplay.tsx
"use client";

import React, { useState, useEffect } from 'react';
import { MOCK_API_URL } from '../config/constants';

interface EcosystemStats {
  pollutionLevel: number;
  totalPopulation: number;
  activeSponsors: number; // Count for simplicity
}

const StatsDisplay: React.FC = () => {
  const [stats, setStats] = useState<EcosystemStats | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      setIsLoading(true);
      setError(null);
      try {
        const response = await fetch(`${MOCK_API_URL}/stats`);
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data: EcosystemStats = await response.json();
        setStats(data);
      } catch (e) {
        console.error("Failed to fetch ecosystem stats:", e);
        setError("Could not load stats.");
        setStats(null); // Clear stats on error
      } finally {
        setIsLoading(false);
      }
    };

    fetchStats();
    // Optional: Set up polling to refresh stats periodically
    const intervalId = setInterval(fetchStats, 10000); // Refresh every 10 seconds

    return () => clearInterval(intervalId); // Cleanup interval on unmount
  }, []);

  return (
    <div className="text-cyan-200">
      <h2 className="text-xl font-semibold mb-3 text-cyan-100 border-b border-cyan-700 pb-1">Ecosystem Stats</h2>
      {isLoading && !stats && <p>Loading stats...</p>} {/* Show loading only initially */}
      {error && <p className="text-red-400">{error}</p>}
      {stats && (
        <ul className="space-y-1 text-sm">
          <li><span className="font-medium text-cyan-300">Pollution Level:</span> {stats.pollutionLevel}%</li>
          <li><span className="font-medium text-cyan-300">Total Fish Population:</span> {stats.totalPopulation}</li>
          <li><span className="font-medium text-cyan-300">Active Sponsors:</span> {stats.activeSponsors}</li>
          {/* Add more stats as needed */}
        </ul>
      )}
    </div>
  );
};

export default StatsDisplay;

