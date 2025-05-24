// /home/ubuntu/aquachain_mvp/frontend/src/app/layout.tsx
"use client";

import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { SuiClientProvider, WalletProvider } from "@mysten/dapp-kit";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { getFullnodeUrl } from "@mysten/sui/client";
import "@mysten/dapp-kit/dist/index.css";

const inter = Inter({ subsets: ["latin"] });

// Sui network configuration (using testnet for development)
const networks = {
	testnet: { url: getFullnodeUrl("testnet") },
	// mainnet: { url: getFullnodeUrl("mainnet") }, // Uncomment for mainnet
	// devnet: { url: getFullnodeUrl("devnet") }, // Uncomment for devnet
};

const queryClient = new QueryClient();

// No explicit Metadata export needed when using "use client"
// export const metadata: Metadata = {
//   title: "Aquachain MVP",
//   description: "Aquachain Memecoin Ecosystem Demo",
// };

export default function RootLayout({
	children,
}: Readonly<{
	children: React.ReactNode;
}>) {
	return (
		<html lang="en">
			<body className={`${inter.className} bg-blue-950 text-white`}>
				<QueryClientProvider client={queryClient}>
					<SuiClientProvider networks={networks} defaultNetwork="testnet">
						<WalletProvider autoConnect>
							{/* Header/Navbar could go here */}
							<main className="container mx-auto p-4">
								{children}
							</main>
							{/* Footer could go here */}
						</WalletProvider>
					</SuiClientProvider>
				</QueryClientProvider>
			</body>
		</html>
	);
}

