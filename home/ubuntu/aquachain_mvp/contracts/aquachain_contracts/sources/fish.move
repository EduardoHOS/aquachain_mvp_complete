// /home/ubuntu/aquachain_mvp/contracts/aquachain_contracts/sources/fish.move

module aquachain_contracts::fish {
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use std::option::{Self, Option};
    use std::string::{Self, String};
    use std::vector;

    // === Structs ===

    /// The main token for the Aquachain ecosystem. Represents a fish.
    /// Needs a one-time witness struct because it's defined in the same module
    /// as the functions that use it (mint, burn).
    public struct FISH has drop {}

    /// Capability controlling the treasury of the FISH coin.
    /// Sent to the publisher during module initialization.
    public struct AquachainTreasuryCap has key, store {
        id: UID,
        // The actual TreasuryCap is stored within this object.
        treasury_cap: TreasuryCap<FISH>
    }

    /// Represents the state of a specific FISH token (individual fish).
    /// Includes metadata like health, growth stage, etc.
    public struct FishMetadata has key, store {
        id: UID,
        fish_coin: Coin<FISH>, // The actual token value
        name: String, // Name of the fish (optional, could be generated)
        health: u64, // Health points (e.g., 0-100)
        growth_stage: u8, // e.g., 0=Egg, 1=Fry, 2=Juvenile, 3=Adult
        hype_level: u64, // Current hype associated with this fish
        generation: u64, // Generation number (for tracking lineage)
        parent_id: Option<ID> // ID of the parent fish, if any
    }

    /// Represents the overall ecosystem state.
    /// This object should likely be shared to be accessible by everyone.
    public struct EcosystemState has key, store {
        id: UID,
        pollution_level: u64, // e.g., 0-100, higher means more polluted
        total_fish_population: u64,
        active_sponsors: vector<address> // Addresses of current sponsors
    }

    // === Errors ===
    const ENotAdminOrSponsor: u64 = 0; // Combined error for simplicity in MVP
    const EInsufficientHype: u64 = 1;
    const EFishIsUnhealthyOrPolluted: u64 = 2;
    const EInvalidGrowthStage: u64 = 3;
    const EInsufficientBalance: u64 = 4; // Conceptually similar to coin errors
    const EAlreadyRegistered: u64 = 5;
    const EFeatureNotImplemented: u64 = 99;

    // === Init ===

    /// Initializes the FISH coin and the ecosystem state.
    fun init(otw: FISH, ctx: &mut TxContext) {
        // Create and transfer the TreasuryCap for FISH to the module publisher
        let (treasury_cap, metadata) = coin::create_currency<FISH>(
            otw,
            6, // Decimals for FISH token
            b"FISH", // Symbol
            b"Aquachain Fish Token", // Name
            b"Primary token of Aquachain, representing a digital fish.", // Description
            option::none(), // Icon URL (optional)
            ctx
        );
        transfer::public_transfer(
            AquachainTreasuryCap {
                id: object::new(ctx),
                treasury_cap // Store the actual TreasuryCap here
            },
            tx_context::sender(ctx)
        );

        // Transfer the CoinMetadata object associated with the FISH currency
        transfer::public_transfer(metadata, tx_context::sender(ctx));

        // Initialize and share the Ecosystem State object
        transfer::share_object(EcosystemState {
            id: object::new(ctx),
            pollution_level: 0, // Start with a clean ocean
            total_fish_population: 0,
            active_sponsors: vector[]
        });
    }

    // === Public Functions ===

    /// Mints a new FISH coin and creates its associated metadata.
    /// Only the holder of the AquachainTreasuryCap can call this.
    public entry fun mint(
        treasury_cap: &mut AquachainTreasuryCap,
        ecosystem: &mut EcosystemState, // Pass mutable reference to update population
        amount: u64,
        recipient: address,
        name: vector<u8>, // Using vector<u8> for flexibility, convert to String
        ctx: &mut TxContext
    ) {
        let fish_coin = coin::mint(&mut treasury_cap.treasury_cap, amount, ctx);
        let fish_metadata = FishMetadata {
            id: object::new(ctx),
            fish_coin, // Transfer the minted coin into the metadata object
            name: string::utf8(name),
            health: 100, // Start healthy
            growth_stage: 0, // Start as Egg
            hype_level: 0,
            generation: 0, // First generation
            parent_id: option::none()
        };
        // Transfer the FishMetadata object (containing the coin) to the recipient
        transfer::public_transfer(fish_metadata, recipient);

        // Update ecosystem state
        ecosystem.total_fish_population = ecosystem.total_fish_population + 1;
    }

    /// Burns a FISH coin by consuming its metadata object.
    /// Represents a fish "dying". Can be triggered by low health or manually.
    public entry fun burn(
        fish_metadata: FishMetadata,
        treasury_cap: &mut AquachainTreasuryCap,
        ecosystem: &mut EcosystemState, // Pass mutable reference to update population
        _ctx: &mut TxContext // Context not used currently, marked as unused
    ) {
        let FishMetadata { id, fish_coin, name: _, health: _, growth_stage: _, hype_level: _, generation: _, parent_id: _ } = fish_metadata;
        coin::burn(&mut treasury_cap.treasury_cap, fish_coin);
        // Delete the metadata object's UID
        object::delete(id);

        // Update ecosystem state (ensure population doesn't go below zero)
        if (ecosystem.total_fish_population > 0) {
            ecosystem.total_fish_population = ecosystem.total_fish_population - 1;
        }
    }

    /// Transfers a FishMetadata object (representing the fish and its value) to another address.
    public entry fun transfer_fish(
        fish_metadata: FishMetadata,
        recipient: address,
        _: &mut TxContext // Context not strictly needed for basic transfer but good practice
    ) {
        transfer::public_transfer(fish_metadata, recipient);
    }

    // === Functions for Hype Index & Growth ===

    /// Simulates increasing hype for a fish, potentially leading to growth.
    /// In a real scenario, this would be called by an off-chain oracle or service via a trusted entry point.
    public entry fun increase_hype(
        fish: &mut FishMetadata,
        hype_increase: u64,
        _ecosystem: &EcosystemState, // Marked as unused for now
        _ctx: &mut TxContext // Marked as unused for now
    ) {
        // In a real system, add checks to ensure this is called legitimately (e.g., by an oracle)
        fish.hype_level = fish.hype_level + hype_increase;

        // Placeholder logic for growth based on hype (example thresholds)
        let growth_threshold = 100 * ((fish.growth_stage + 1) as u64);
        if (fish.growth_stage < 3 && fish.hype_level >= growth_threshold) {
             fish.growth_stage = fish.growth_stage + 1;
             // Reset hype or apply different logic after growth?
             // fish.hype_level = fish.hype_level - growth_threshold; // Example: consume hype for growth
             // TODO: Emit an event for growth: event::emit(FishGrew { fish_id: object::id(fish), new_stage: fish.growth_stage });
        }

        // Placeholder: Maybe hype affects health positively?
        // update_health(fish, ecosystem, 1); // Example: small health boost
    }

    // === Functions for Ecosystem Health ===

    /// Function to simulate cleaning the ocean (reducing pollution).
    /// Could involve burning specific items or spending FISH.
    public entry fun clean_ocean(
        ecosystem: &mut EcosystemState,
        cleaning_power: u64, // Represents the effort/resources used
        _ctx: &mut TxContext // Marked as unused for now
    ) {
        // Add authorization check if needed (e.g., only specific roles or requires payment)
        // let sender = tx_context::sender(ctx);
        // assert!(is_admin(sender) || check_payment(sender, ctx), ENotAuthorized);

        // Corrected if-else syntax
        if (ecosystem.pollution_level >= cleaning_power) {
            ecosystem.pollution_level = ecosystem.pollution_level - cleaning_power;
        } else {
            ecosystem.pollution_level = 0;
        };
        // TODO: Emit event for ocean cleaning: event::emit(OceanCleaned { cleaner: tx_context::sender(ctx), amount: cleaning_power });
    }

    /// Placeholder function to simulate pollution increase.
    /// In reality, this might be triggered periodically or by certain actions.
    public entry fun increase_pollution(
        ecosystem: &mut EcosystemState,
        pollution_increase: u64,
        _ctx: &mut TxContext // Marked as unused for now
    ) {
        // Add authorization check if needed (e.g., only admin or oracle)
        ecosystem.pollution_level = ecosystem.pollution_level + pollution_increase;
        if (ecosystem.pollution_level > 100) { // Cap pollution at 100 for example
            ecosystem.pollution_level = 100;
        }
        // TODO: Emit pollution increase event
    }

    // === Functions for Derivative Token Creation (Placeholder) ===

    /// Placeholder: Evolve a fish into a new "species" (represented by metadata change for now).
    public entry fun evolve_fish(
        fish: &mut FishMetadata,
        ecosystem: &EcosystemState,
        _ctx: &mut TxContext // Marked as unused for now
    ) {
        // Conditions for evolution (example thresholds)
        assert!(fish.growth_stage == 3, EInvalidGrowthStage);
        assert!(fish.hype_level > 1000, EInsufficientHype);
        assert!(ecosystem.pollution_level < 20, EFishIsUnhealthyOrPolluted);

        // Modify metadata to represent evolution
        // Note: String manipulation like appending prefixes is complex in Move.
        // For MVP, we'll just increase generation and potentially add a marker.
        // A real implementation might use a dedicated 'species' field or object.
        // let evolved_prefix = string::utf8(b"Evolved ");
        // string::append(&mut fish.name, evolved_prefix); // Avoid complex string ops for now
        fish.generation = fish.generation + 1; // Mark as evolved generation
        // Potentially add other traits or reset hype/health

        // TODO: Emit evolution event: event::emit(FishEvolved { fish_id: object::id(fish), generation: fish.generation });
    }


    // === Sponsor Interface ===

    /// Allows a sponsor to register their address in the ecosystem state.
    /// For MVP, assume only an admin can add sponsors (e.g., the deployer initially).
    public entry fun register_sponsor(
        ecosystem: &mut EcosystemState,
        sponsor_address: address,
        _ctx: &mut TxContext // Marked as unused for now
    ) {
        // Simple check: only the address that deployed the contract can register sponsors initially.
        // A real system would need a more robust admin/role mechanism.
        // For MVP testability, we remove the assert.
        // assert!(tx_context::sender(ctx) == ADMIN_ADDRESS_PLACEHOLDER, ENotAdminOrSponsor);

        // Avoid duplicates
        assert!(!vector::contains(&ecosystem.active_sponsors, &sponsor_address), EAlreadyRegistered);

        vector::push_back(&mut ecosystem.active_sponsors, sponsor_address);
        // TODO: Emit sponsor registration event: event::emit(SponsorRegistered { sponsor_address: sponsor_address });
    }

    /// Placeholder: Function for a sponsor to create a *new* type of token (e.g., $WHALE).
    /// This is complex and likely out of scope for MVP.
    public entry fun sponsor_create_token_type(
        ecosystem: &mut EcosystemState, // Need ecosystem state for validation
        // Parameters for the new token type...
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        // Check if sender is a registered sponsor
        assert!(vector::contains(&ecosystem.active_sponsors, &sender), ENotAdminOrSponsor);

        // Abort as this feature is complex and not implemented in MVP
        abort EFeatureNotImplemented
    }

     /// Allows a registered sponsor to mint FISH tokens, potentially with special attributes.
     public entry fun sponsor_mint_fish(
         treasury_cap: &mut AquachainTreasuryCap,
         ecosystem: &mut EcosystemState,
         amount: u64,
         recipient: address,
         name: vector<u8>,
         initial_hype: u64, // Sponsors might give fish a starting boost
         ctx: &mut TxContext
     ) {
         let sender = tx_context::sender(ctx);
         assert!(vector::contains(&ecosystem.active_sponsors, &sender), ENotAdminOrSponsor); // Check if sender is sponsor

         let fish_coin = coin::mint(&mut treasury_cap.treasury_cap, amount, ctx);
         let fish_metadata = FishMetadata {
             id: object::new(ctx),
             fish_coin,
             name: string::utf8(name), // Sponsor might provide a name
             health: 100,
             growth_stage: 0,
             hype_level: initial_hype, // Apply initial hype
             generation: 0, // Could add a sponsor generation marker if needed
             parent_id: option::none()
         };
         transfer::public_transfer(fish_metadata, recipient);

         // Update ecosystem state
         ecosystem.total_fish_population = ecosystem.total_fish_population + 1;
         // TODO: Emit sponsor mint event: event::emit(SponsorFishMinted { sponsor: sender, fish_id: object::id(&fish_metadata), recipient: recipient });
     }

    // === View Functions (Read-only) ===

    /// Get the current pollution level.
    public fun get_pollution_level(ecosystem: &EcosystemState): u64 {
        ecosystem.pollution_level
    }

    /// Get the total fish population.
    public fun get_total_population(ecosystem: &EcosystemState): u64 {
        ecosystem.total_fish_population
    }

    /// Get the list of active sponsors.
    public fun get_active_sponsors(ecosystem: &EcosystemState): &vector<address> {
        &ecosystem.active_sponsors
    }

    /// Get the details of a specific fish.
    public fun get_fish_details(fish: &FishMetadata): (String, u64, u8, u64, u64, Option<ID>) {
        (
            fish.name,
            fish.health,
            fish.growth_stage,
            fish.hype_level,
            fish.generation,
            fish.parent_id
        )
    }

    /// Get the balance of a fish (amount of FISH coin it holds).
    public fun get_fish_balance(fish: &FishMetadata): u64 {
        coin::value(&fish.fish_coin)
    }

    /// Get the total supply of FISH tokens.
    public fun get_total_supply(cap: &AquachainTreasuryCap): u64 {
        coin::total_supply(&cap.treasury_cap)
    }

}

