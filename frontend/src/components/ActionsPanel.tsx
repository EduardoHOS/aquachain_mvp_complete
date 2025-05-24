// /home/ubuntu/aquachain_mvp/frontend/src/components/ActionsPanel.tsx
"use client";

import React, { useState } from 'react';
import { useCurrentAccount, useSignAndExecuteTransaction } from '@mysten/dapp-kit';
import { Transaction } from '@mysten/sui/transactions'; // Use Transaction instead of TransactionBlock
import { MOCK_API_URL, PACKAGE_ID, ECOSYSTEM_STATE_ID, TREASURY_CAP_ID } from '../config/constants';

const ActionsPanel: React.FC = () => {
  const currentAccount = useCurrentAccount();
  const { mutate: signAndExecute } = useSignAndExecuteTransaction();
  const [isSpawning, setIsSpawning] = useState(false);
  const [isCleaning, setIsCleaning] = useState(false);

  const handleSpawnFish = async () => {
    if (!currentAccount) return alert('Please connect your wallet first!');
    setIsSpawning(true);
    console.log('Attempting to spawn fish via mock API...');

    try {
      // Simulate engagement check and get spawn permission/data from mock API
      const hypeResponse = await fetch(`${MOCK_API_URL}/simulate/hype`, { method: 'POST' });
      if (!hypeResponse.ok) throw new Error('Failed to simulate hype');
      const hypeData = await hypeResponse.json();
      console.log('Simulated hype:', hypeData);

      // In a real scenario, the hypeData might influence the transaction
      // For MVP, we just trigger the contract call if hype simulation is ok

      alert('Hype simulated! Now building transaction... (Replace placeholders with actual IDs)');

      // --- Placeholder for actual Contract Interaction ---
      // const txb = new Transaction();
      // txb.moveCall({
      //   target: `${PACKAGE_ID}::fish::mint`, // Assuming a mint function triggered by engagement
      //   arguments: [
      //      txb.object(TREASURY_CAP_ID), // Requires Treasury Cap (Admin/Sponsor? Or different mechanism?)
      //      txb.object(ECOSYSTEM_STATE_ID),
      //      txb.pure(1), // Amount to mint (e.g., 1 coin per fish)
      //      txb.pure(currentAccount.address),
      //      txb.pure(b"NewSpawnedFish"), // Generate or pass name
      //   ],
      // });
      // signAndExecute({ transaction: txb }, {
      //   onSuccess: (result) => {
      //     console.log('Fish spawned via contract:', result);
      //     alert('Fish Spawned Successfully!');
      //     setIsSpawning(false);
      //     // TODO: Trigger UI refresh for fish list
      //   },
      //   onError: (error) => {
      //     console.error('Spawn failed:', error);
      //     alert(`Spawn Failed: ${error.message}`);
      //     setIsSpawning(false);
      //   },
      // });
      // --- End Placeholder ---

      // Mock API call for simulation purposes if contract call is placeholder
      const spawnResponse = await fetch(`${MOCK_API_URL}/simulate/spawn`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ userAddress: currentAccount.address })
      });
      if (!spawnResponse.ok) throw new Error('Mock spawn failed');
      const spawnData = await spawnResponse.json();
      alert(`Mock Spawn Successful: ${spawnData.message}`);
      setIsSpawning(false);
      // TODO: Trigger UI refresh

    } catch (error: any) {
      console.error('Spawn process failed:', error);
      alert(`Spawn process failed: ${error.message}`);
      setIsSpawning(false);
    }
  };

  const handleCleanOcean = async () => {
    if (!currentAccount) return alert('Please connect your wallet first!');
    setIsCleaning(true);
    console.log('Attempting to clean ocean...');

    alert('Building clean ocean transaction... (Replace placeholders with actual IDs)');

    // --- Placeholder for actual Contract Interaction ---
    // const txb = new Transaction();
    // txb.moveCall({
    //   target: `${PACKAGE_ID}::fish::clean_ocean`,
    //   arguments: [
    //       txb.object(ECOSYSTEM_STATE_ID),
    //       txb.pure(10) // Example cleaning power
    //       // Potentially add payment/burn mechanism here if required by contract
    //   ],
    // });
    // signAndExecute({ transaction: txb }, {
    //   onSuccess: (result) => {
    //     console.log('Ocean cleaned via contract:', result);
    //     alert('Ocean Cleaned Successfully!');
    //     setIsCleaning(false);
    //      // TODO: Trigger UI refresh for stats
    //   },
    //   onError: (error) => {
    //     console.error('Clean ocean failed:', error);
    //     alert(`Clean Ocean Failed: ${error.message}`);
    //     setIsCleaning(false);
    //   },
    // });
    // --- End Placeholder ---

     // Mock API call for simulation purposes
    try {
        const cleanResponse = await fetch(`${MOCK_API_URL}/simulate/clean`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cleaningPower: 10 })
        });
        if (!cleanResponse.ok) throw new Error('Mock clean failed');
        const cleanData = await cleanResponse.json();
        alert(`Mock Clean Successful: ${cleanData.message}`);
        setIsCleaning(false);
        // TODO: Trigger UI refresh for stats
    } catch (error: any) {
        console.error('Clean process failed:', error);
        alert(`Clean process failed: ${error.message}`);
        setIsCleaning(false);
    }
  };

  return (
    <div className="text-cyan-200">
      <h2 className="text-xl font-semibold mb-3 text-cyan-100 border-b border-cyan-700 pb-1">Actions</h2>
      <div className="space-y-3">
        <button
          onClick={handleSpawnFish}
          disabled={!currentAccount || isSpawning}
          className="w-full bg-green-600 hover:bg-green-700 disabled:bg-gray-500 disabled:cursor-not-allowed text-white font-bold py-2 px-4 rounded transition duration-150 ease-in-out"
        >
          {isSpawning ? 'Spawning...' : 'Spawn New Fish (Simulate Engagement)'}
        </button>
        <button
          onClick={handleCleanOcean}
          disabled={!currentAccount || isCleaning}
          className="w-full bg-red-600 hover:bg-red-700 disabled:bg-gray-500 disabled:cursor-not-allowed text-white font-bold py-2 px-4 rounded transition duration-150 ease-in-out"
        >
          {isCleaning ? 'Cleaning...' : 'Clean Ocean (Simulate Burn)'}
        </button>
        {/* Add more actions as needed */}
      </div>
    </div>
  );
};

export default ActionsPanel;

