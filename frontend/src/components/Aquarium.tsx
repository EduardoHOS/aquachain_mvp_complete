// /home/ubuntu/aquachain_mvp/frontend/src/components/Aquarium.tsx
"use client";

import React, { useState, useEffect } from 'react';
import { useCurrentAccount } from '@mysten/dapp-kit';
import { MOCK_API_URL, MOCK_USER_ADDRESS_1 } from '../config/constants'; // Import API URL

// Define the structure for a fish object (matching API data)
interface Fish {
  id: string;
  name: string;
  growthStage: number;
  hypeLevel: number;
  health: number;
  owner: string;
  // Add position/visual properties for animation
  x: number;
  y: number;
  vx: number; // velocity x
  vy: number; // velocity y
}

const Aquarium: React.FC = () => {
  const currentAccount = useCurrentAccount();
  const [fishes, setFishes] = useState<Fish[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchFishes = async (address: string) => {
      setIsLoading(true);
      setError(null);
      try {
        // Use mock address if needed for testing, otherwise use connected account
        const fetchAddress = address || MOCK_USER_ADDRESS_1;
        const response = await fetch(`${MOCK_API_URL}/fishes/${fetchAddress}`);
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        let data: Fish[] = await response.json();
        // Initialize visual properties for animation
        data = data.map(fish => ({
          ...fish,
          x: Math.random() * 750 + 25, // Random initial position within bounds
          y: Math.random() * 450 + 25,
          vx: (Math.random() - 0.5) * 2, // Random initial velocity
          vy: (Math.random() - 0.5) * 2,
        }));
        setFishes(data);
      } catch (e) {
        console.error("Failed to fetch user fishes:", e);
        setError("Could not load fish data.");
        setFishes([]); // Clear fishes on error
      } finally {
        setIsLoading(false);
      }
    };

    if (currentAccount) {
      fetchFishes(currentAccount.address);
    } else {
      // Optionally fetch for a default mock user or show empty state
      // fetchFishes(MOCK_USER_ADDRESS_1); // Example: load mock user 1 if not connected
       setFishes([]); // Clear fishes if no account is connected
       setError(null);
       setIsLoading(false);
    }
  }, [currentAccount]);

  // Animation loop using requestAnimationFrame for smoother animation
  useEffect(() => {
    let animationFrameId: number;
    const animate = () => {
      setFishes(prevFishes =>
        prevFishes.map(fish => {
          let newX = fish.x + fish.vx;
          let newY = fish.y + fish.vy;
          let newVx = fish.vx;
          let newVy = fish.vy;

          // Boundary collision detection (adjust dimensions as needed)
          const aquariumWidth = 800; // Example width
          const aquariumHeight = 550; // Example height (leaving space for sand)
          const fishSize = 40; // Approximate size for collision

          if (newX < fishSize / 2 || newX > aquariumWidth - fishSize / 2) {
            newVx = -newVx;
            newX = fish.x + newVx; // Adjust position slightly after bounce
          }
          if (newY < fishSize / 2 || newY > aquariumHeight - fishSize / 2) {
            newVy = -newVy;
            newY = fish.y + newVy; // Adjust position slightly after bounce
          }

          // Add slight random direction change for more natural movement
          if (Math.random() < 0.01) newVx += (Math.random() - 0.5) * 0.5;
          if (Math.random() < 0.01) newVy += (Math.random() - 0.5) * 0.5;

          // Clamp velocity to prevent excessive speed
          newVx = Math.max(-2, Math.min(2, newVx));
          newVy = Math.max(-2, Math.min(2, newVy));

          return { ...fish, x: newX, y: newY, vx: newVx, vy: newVy };
        })
      );
      animationFrameId = requestAnimationFrame(animate);
    };

    animationFrameId = requestAnimationFrame(animate);

    return () => cancelAnimationFrame(animationFrameId); // Cleanup animation frame
  }, []); // Empty dependency array means this effect runs once on mount

  const getFishEmoji = (stage: number) => {
    switch (stage) {
      case 0: return '🥚'; // Egg
      case 1: return '🐠'; // Fry/Small Fish
      case 2: return '🐟'; // Juvenile/Medium Fish
      case 3: return '🐡'; // Adult/Large Fish
      default: return '❓';
    }
  };

  return (
    <div className="w-full h-[600px] bg-gradient-to-b from-blue-600 to-blue-800 rounded-lg relative overflow-hidden border-2 border-cyan-400">
      {isLoading && <div className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-50 text-white z-20">Loading Aquarium...</div>}
      {error && <div className="absolute inset-0 flex items-center justify-center text-red-400 bg-black bg-opacity-50 z-20">{error}</div>}
      {!currentAccount && !isLoading && !error && <div className="absolute inset-0 flex items-center justify-center text-gray-400 z-10">Connect wallet to see your fish</div>}

      {fishes.map((fish) => (
        <div
          key={fish.id}
          className="absolute text-center group cursor-pointer z-10"
          style={{
            left: `${fish.x - 20}px`, // Center emoji horizontally
            top: `${fish.y - 20}px`, // Center emoji vertically
            transition: 'left 0.05s linear, top 0.05s linear' // Smooth movement
          }}
          title={`Name: ${fish.name}\nHealth: ${fish.health}\nHype: ${fish.hypeLevel}`}
        >
          <span className={`text-4xl transform transition-transform duration-200 ${fish.vx > 0 ? 'scale-x-100' : 'scale-x-[-100]'}`}>
            {getFishEmoji(fish.growthStage)}
          </span>
          <div className="absolute -bottom-4 left-1/2 transform -translate-x-1/2 text-xs text-cyan-200 opacity-0 group-hover:opacity-100 transition-opacity duration-300 whitespace-nowrap">
            {fish.name}
          </div>
        </div>
      ))}

      {/* Background elements */}
      <div className="absolute bottom-0 left-0 w-full h-1/6 bg-gradient-to-t from-yellow-800 via-yellow-700 to-transparent opacity-60 z-0"></div> {/* Sand */}
      {/* Add more background elements like bubbles, plants etc. here */}
      {[...Array(20)].map((_, i) => (
          <div key={i} className="absolute bottom-0 left-0 w-1 h-1 bg-white rounded-full opacity-30 animate-bubble"
               style={{ left: `${Math.random() * 100}%`, animationDelay: `${Math.random() * 5}s`, animationDuration: `${Math.random() * 5 + 5}s` }}></div>
      ))}
    </div>
  );
};

// Add CSS for bubble animation in globals.css or here if using styled-components/tailwind plugins
/* Example in globals.css:
@keyframes bubble {
  0% { transform: translateY(0); opacity: 0.3; }
  90% { opacity: 0.3; }
  100% { transform: translateY(-600px); opacity: 0; }
}
.animate-bubble {
  animation: bubble linear infinite;
}
*/

export default Aquarium;

