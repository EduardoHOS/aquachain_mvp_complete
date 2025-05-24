// /home/ubuntu/aquachain_mvp/frontend/src/components/SponsorInterface.tsx
"use client";

import React, { useState, useEffect } from 'react';
import { useCurrentAccount, useSignAndExecuteTransaction } from '@mysten/dapp-kit';
import { Transaction } from '@mysten/sui/transactions';
import { MOCK_API_URL, PACKAGE_ID, ECOSYSTEM_STATE_ID, TREASURY_CAP_ID, MOCK_SPONSOR_ADDRESS } from '../config/constants';

const SponsorInterface: React.FC = () => {
  const currentAccount = useCurrentAccount();
  const { mutate: signAndExecute } = useSignAndExecuteTransaction();
  const [recipientAddress, setRecipientAddress] = useState('');
  const [fishName, setFishName] = useState('');
  const [initialHype, setInitialHype] = useState('0');
  const [isRegistering, setIsRegistering] = useState(false);
  const [isMinting, setIsMinting] = useState(false);

  // Placeholder check - replace with actual contract check or API call
  // For MVP, we can check against a mock sponsor address or fetch sponsor status from API/contract
  const [isSponsor, setIsSponsor] = useState(false);

  useEffect(() => {
    // Simulate checking sponsor status when account changes
    if (currentAccount) {
      // TODO: Replace with actual check (e.g., read from EcosystemState or dedicated sponsor registry)
      // For now, compare with mock address
      setIsSponsor(currentAccount.address === MOCK_SPONSOR_ADDRESS);
    } else {
      setIsSponsor(false);
    }
  }, [currentAccount]);

  const handleRegisterSponsor = async () => {
    if (!currentAccount) return alert('Please connect your wallet first!');
    setIsRegistering(true);
    console.log('Attempting to register as sponsor...');

    alert('Building register sponsor transaction... (Replace placeholders - likely Admin Only)');

    // --- Placeholder for actual Contract Interaction (Admin Action) ---
    // const txb = new Transaction();
    // txb.moveCall({
    //   target: `${PACKAGE_ID}::fish::register_sponsor`,
    //   arguments: [
    //       txb.object(ECOSYSTEM_STATE_ID),
    //       txb.pure(currentAccount.address) // Address to register
    //   ],
    // });
    // signAndExecute({ transaction: txb }, {
    //   onSuccess: (result) => {
    //     console.log('Sponsor registered:', result);
    //     alert('Sponsor Registered Successfully! (Requires Admin)');
    //     setIsSponsor(true); // Update state optimistically or re-fetch
    //     setIsRegistering(false);
    //   },
    //   onError: (error) => {
    //     console.error('Sponsor registration failed:', error);
    //     alert(`Sponsor Registration Failed: ${error.message}`);
    //     setIsRegistering(false);
    //   },
    // });
    // --- End Placeholder ---

    // Simulate delay for mock
    await new Promise(resolve => setTimeout(resolve, 1000));
    alert('Mock registration complete (Admin action simulated). Please use the mock sponsor address for testing minting.');
    setIsRegistering(false);
  };

  const handleSponsorMint = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!currentAccount) return alert('Please connect your wallet first!');
    if (!isSponsor) return alert('Only registered sponsors can mint special fish.');
    if (!recipientAddress || !fishName) return alert('Please provide recipient address and fish name.');

    setIsMinting(true);
    console.log(`Sponsor minting fish: ${fishName} for ${recipientAddress} with ${initialHype} hype`);

    alert('Building sponsor mint transaction... (Replace placeholders with actual IDs)');

    // --- Placeholder for actual Contract Interaction ---
    // const txb = new Transaction();
    // txb.moveCall({
    //   target: `${PACKAGE_ID}::fish::sponsor_mint_fish`,
    //   arguments: [
    //     txb.object(TREASURY_CAP_ID),
    //     txb.object(ECOSYSTEM_STATE_ID),
    //     txb.pure(1), // Mint amount (adjust as needed, e.g., 1 coin per fish)
    //     txb.pure(recipientAddress),
    //     txb.pure(fishName),
    //     txb.pure(parseInt(initialHype, 10) || 0),
    //   ],
    // });
    // signAndExecute({ transaction: txb }, {
    //   onSuccess: (result) => {
    //     console.log('Sponsor mint successful:', result);
    //     alert('Sponsor Mint Successful!');
    //     setIsMinting(false);
    //     // Clear form or give feedback
    //     setRecipientAddress('');
    //     setFishName('');
    //     setInitialHype('0');
    //     // TODO: Trigger UI refresh for fish list/stats
    //   },
    //   onError: (error) => {
    //     console.error('Sponsor mint failed:', error);
    //     alert(`Sponsor Mint Failed: ${error.message}`);
    //     setIsMinting(false);
    //   },
    // });
    // --- End Placeholder ---

    // Simulate delay for mock
    await new Promise(resolve => setTimeout(resolve, 1500));
    alert(`Mock Sponsor Mint Successful: Fish '${fishName}' minted for ${recipientAddress}.`);
    setIsMinting(false);
    setRecipientAddress('');
    setFishName('');
    setInitialHype('0');
    // TODO: Trigger UI refresh
  };

  return (
    <div className="text-cyan-200">
      <h2 className="text-xl font-semibold mb-3 text-cyan-100 border-b border-cyan-700 pb-1">Sponsor Zone</h2>
      {currentAccount ? (
        isSponsor ? (
          <form onSubmit={handleSponsorMint} className="space-y-3 text-sm">
            <p className="text-green-400">You are recognized as a sponsor.</p>
            <div>
              <label htmlFor="recipient" className="block mb-1 font-medium">Recipient Address:</label>
              <input
                type="text"
                id="recipient"
                value={recipientAddress}
                onChange={(e) => setRecipientAddress(e.target.value)}
                placeholder="0x..."
                required
                className="w-full p-1.5 bg-blue-900 border border-cyan-700 rounded focus:ring-cyan-500 focus:border-cyan-500 text-white"
              />
            </div>
            <div>
              <label htmlFor="fishName" className="block mb-1 font-medium">Fish Name:</label>
              <input
                type="text"
                id="fishName"
                value={fishName}
                onChange={(e) => setFishName(e.target.value)}
                placeholder="SpecialFish"
                required
                className="w-full p-1.5 bg-blue-900 border border-cyan-700 rounded focus:ring-cyan-500 focus:border-cyan-500 text-white"
              />
            </div>
            <div>
              <label htmlFor="initialHype" className="block mb-1 font-medium">Initial Hype:</label>
              <input
                type="number"
                id="initialHype"
                value={initialHype}
                onChange={(e) => setInitialHype(e.target.value)}
                min="0"
                required
                className="w-full p-1.5 bg-blue-900 border border-cyan-700 rounded focus:ring-cyan-500 focus:border-cyan-500 text-white"
              />
            </div>
            <button
              type="submit"
              disabled={isMinting}
              className="w-full bg-purple-600 hover:bg-purple-700 disabled:bg-gray-500 disabled:cursor-not-allowed text-white font-bold py-2 px-4 rounded transition duration-150 ease-in-out"
            >
              {isMinting ? 'Minting...' : 'Sponsor Mint Fish'}
            </button>
          </form>
        ) : (
          <div>
            <p className="mb-3 text-yellow-400">You are not currently registered as a sponsor.</p>
            <button
              onClick={handleRegisterSponsor}
              disabled={isRegistering}
              className="w-full bg-yellow-600 hover:bg-yellow-700 disabled:bg-gray-500 disabled:cursor-not-allowed text-white font-bold py-2 px-4 rounded transition duration-150 ease-in-out"
            >
              {isRegistering ? 'Registering...' : 'Register as Sponsor (Admin Action)'}
            </button>
          </div>
        )
      ) : (
        <p>Connect wallet to access sponsor features.</p>
      )}
    </div>
  );
};

export default SponsorInterface;

