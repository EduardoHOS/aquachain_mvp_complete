// /home/ubuntu/aquachain_mvp/contracts/aquachain_contracts/tests/fish_tests.move

#[test_only]
module aquachain_contracts::fish_tests {
    use sui::test_scenario::{Self, Scenario, next_tx, ctx};
    use sui::coin::{Self, Coin, balance};
    use sui::object::{Self, ID, uid_to_inner};
    use sui::transfer;
    use sui::types::address_from_bytes;
    use std::string;
    use std::option;
    use std::vector;

    use aquachain_contracts::fish::{Self, FISH, AquachainTreasuryCap, FishMetadata, EcosystemState};

    // === Test Addresses (Use actual addresses or aliases defined in Move.toml dev-addresses if needed) ===
    // For simplicity in test_scenario, we use aliases directly in next_tx
    const ADMIN_ADDR: address = @0xAD;
    const USER1_ADDR: address = @0 U1;
    const USER2_ADDR: address = @0 U2;
    const SPONSOR1_ADDR: address = @0 SP1;

    // === Helper Functions ===

    fun setup_scenario(): (Scenario, AquachainTreasuryCap, EcosystemState) {
        let scenario = test_scenario::begin(ADMIN_ADDR);

        // Initialize the module
        {
            next_tx(&mut scenario, ADMIN_ADDR);
            fish::init(FISH {}, ctx(&mut scenario));
        };

        // Get the TreasuryCap and EcosystemState objects
        next_tx(&mut scenario, ADMIN_ADDR);
        let treasury_cap = test_scenario::take_from_sender<AquachainTreasuryCap>(&scenario);
        let ecosystem_state = test_scenario::take_shared<EcosystemState>(&scenario);

        (scenario, treasury_cap, ecosystem_state)
    }

    // === Test Functions ===

    #[test]
    fun test_init_and_mint() {
        let (mut scenario, mut treasury_cap, mut ecosystem_state) = setup_scenario();

        // Mint a fish for USER1_ADDR
        let initial_supply = fish::get_total_supply(&treasury_cap); // Use getter
        let initial_population = fish::get_total_population(&ecosystem_state);
        let mint_amount = 1000;
        let fish_name = b"Nemo";

        next_tx(&mut scenario, ADMIN_ADDR);
        fish::mint(&mut treasury_cap, &mut ecosystem_state, mint_amount, USER1_ADDR, fish_name, ctx(&mut scenario));

        // Check supply and population
        assert!(fish::get_total_supply(&treasury_cap) == initial_supply + mint_amount, 1);
        assert!(fish::get_total_population(&ecosystem_state) == initial_population + 1, 2);

        // Check USER1_ADDR received the FishMetadata
        next_tx(&mut scenario, USER1_ADDR);
        let fish_metadata = test_scenario::take_from_sender<FishMetadata>(&scenario);
        assert!(fish::get_fish_balance(&fish_metadata) == mint_amount, 3);
        let (name, health, stage, hype, gen, parent) = fish::get_fish_details(&fish_metadata);
        assert!(name == string::utf8(fish_name), 4);
        assert!(health == 100, 5);
        assert!(stage == 0, 6);
        assert!(hype == 0, 7);
        assert!(gen == 0, 8);
        assert!(parent == option::none(), 9);

        // Return objects to scenario
        test_scenario::return_to_sender(&scenario, fish_metadata);
        test_scenario::return_shared(ecosystem_state);
        test_scenario::return_to_sender(&scenario, treasury_cap);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_fish() {
        let (mut scenario, mut treasury_cap, mut ecosystem_state) = setup_scenario();

        // Mint a fish for USER1_ADDR
        next_tx(&mut scenario, ADMIN_ADDR);
        fish::mint(&mut treasury_cap, &mut ecosystem_state, 500, USER1_ADDR, b"Dory", ctx(&mut scenario));

        // USER1_ADDR transfers the fish to USER2_ADDR
        next_tx(&mut scenario, USER1_ADDR);
        let fish_to_transfer = test_scenario::take_from_sender<FishMetadata>(&scenario);
        fish::transfer_fish(fish_to_transfer, USER2_ADDR, ctx(&mut scenario));

        // Check USER2_ADDR received the fish
        next_tx(&mut scenario, USER2_ADDR);
        let received_fish = test_scenario::take_from_sender<FishMetadata>(&scenario);
        assert!(fish::get_fish_balance(&received_fish) == 500, 1);
        let (name, _, _, _, _, _) = fish::get_fish_details(&received_fish);
        assert!(name == string::utf8(b"Dory"), 2);

        // Return objects
        test_scenario::return_to_sender(&scenario, received_fish);
        test_scenario::return_shared(ecosystem_state);
        test_scenario::return_to_sender(&scenario, treasury_cap);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_burn_fish() {
        let (mut scenario, mut treasury_cap, mut ecosystem_state) = setup_scenario();

        // Mint a fish for USER1_ADDR
        let initial_supply = fish::get_total_supply(&treasury_cap); // Use getter
        let initial_population = fish::get_total_population(&ecosystem_state);
        let mint_amount = 200;
        next_tx(&mut scenario, ADMIN_ADDR);
        fish::mint(&mut treasury_cap, &mut ecosystem_state, mint_amount, USER1_ADDR, b"Gill", ctx(&mut scenario));
        assert!(fish::get_total_population(&ecosystem_state) == initial_population + 1, 0);

        // USER1_ADDR takes the fish, ADMIN_ADDR burns it
        next_tx(&mut scenario, USER1_ADDR);
        let fish_to_burn = test_scenario::take_from_sender<FishMetadata>(&scenario);

        next_tx(&mut scenario, ADMIN_ADDR);
        fish::burn(fish_to_burn, &mut treasury_cap, &mut ecosystem_state, ctx(&mut scenario));

        // Check supply and population decreased
        assert!(fish::get_total_supply(&treasury_cap) == initial_supply, 1); // Supply should be back to initial
        assert!(fish::get_total_population(&ecosystem_state) == initial_population, 2);

        // Return objects
        test_scenario::return_shared(ecosystem_state);
        test_scenario::return_to_sender(&scenario, treasury_cap);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_hype_and_growth() {
        let (mut scenario, mut treasury_cap, mut ecosystem_state) = setup_scenario();

        // Mint a fish for USER1_ADDR
        next_tx(&mut scenario, ADMIN_ADDR);
        fish::mint(&mut treasury_cap, &mut ecosystem_state, 100, USER1_ADDR, b"Bubbles", ctx(&mut scenario));

        // USER1_ADDR increases hype
        next_tx(&mut scenario, USER1_ADDR);
        let mut fish_metadata = test_scenario::take_from_sender<FishMetadata>(&scenario);
        let initial_stage = fish::get_fish_details(&fish_metadata).2;
        assert!(initial_stage == 0, 1); // Starts at stage 0

        // Increase hype enough to grow to stage 1 (threshold 100 * (0+1) = 100)
        fish::increase_hype(&mut fish_metadata, 100, &ecosystem_state, ctx(&mut scenario));
        let (name, health, stage, hype, gen, parent) = fish::get_fish_details(&fish_metadata);
        assert!(stage == 1, 2); // Should grow to stage 1
        // assert!(hype == 0, 3); // Example: check if hype was consumed (depends on implementation)

        // Increase hype enough to grow to stage 2 (threshold 100 * (1+1) = 200)
        fish::increase_hype(&mut fish_metadata, 200, &ecosystem_state, ctx(&mut scenario));
        let (_, _, stage, _, _, _) = fish::get_fish_details(&fish_metadata);
        assert!(stage == 2, 4); // Should grow to stage 2

        // Increase hype enough to grow to stage 3 (threshold 100 * (2+1) = 300)
        fish::increase_hype(&mut fish_metadata, 300, &ecosystem_state, ctx(&mut scenario));
        let (_, _, stage, _, _, _) = fish::get_fish_details(&fish_metadata);
        assert!(stage == 3, 5); // Should grow to stage 3 (Adult)

        // Try to grow beyond max stage
        fish::increase_hype(&mut fish_metadata, 500, &ecosystem_state, ctx(&mut scenario));
        let (_, _, stage, _, _, _) = fish::get_fish_details(&fish_metadata);
        assert!(stage == 3, 6); // Should remain at stage 3

        // Return objects
        test_scenario::return_to_sender(&scenario, fish_metadata);
        test_scenario::return_shared(ecosystem_state);
        test_scenario::return_to_sender(&scenario, treasury_cap);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_ecosystem_pollution() {
        let (mut scenario, mut treasury_cap, mut ecosystem_state) = setup_scenario();

        let initial_pollution = fish::get_pollution_level(&ecosystem_state);
        assert!(initial_pollution == 0, 1);

        // Increase pollution (simulate admin/oracle action)
        next_tx(&mut scenario, ADMIN_ADDR);
        fish::increase_pollution(&mut ecosystem_state, 30, ctx(&mut scenario));
        assert!(fish::get_pollution_level(&ecosystem_state) == 30, 2);

        // Clean the ocean (simulate user/admin action)
        fish::clean_ocean(&mut ecosystem_state, 20, ctx(&mut scenario));
        assert!(fish::get_pollution_level(&ecosystem_state) == 10, 3);

        // Clean more than available
        fish::clean_ocean(&mut ecosystem_state, 50, ctx(&mut scenario));
        assert!(fish::get_pollution_level(&ecosystem_state) == 0, 4);

        // Return objects
        test_scenario::return_shared(ecosystem_state);
        test_scenario::return_to_sender(&scenario, treasury_cap);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_sponsor_functions() {
        let (mut scenario, mut treasury_cap, mut ecosystem_state) = setup_scenario();

        // Register SPONSOR1_ADDR (assuming ADMIN_ADDR can do this for now)
        next_tx(&mut scenario, ADMIN_ADDR);
        fish::register_sponsor(&mut ecosystem_state, SPONSOR1_ADDR, ctx(&mut scenario));
        let sponsors = fish::get_active_sponsors(&ecosystem_state);
        assert!(vector::contains(sponsors, &SPONSOR1_ADDR), 1);

        // SPONSOR1_ADDR mints a fish for USER2_ADDR with initial hype
        next_tx(&mut scenario, SPONSOR1_ADDR);
        let initial_supply = fish::get_total_supply(&treasury_cap); // Use getter
        let initial_population = fish::get_total_population(&ecosystem_state);
        fish::sponsor_mint_fish(&mut treasury_cap, &mut ecosystem_state, 300, USER2_ADDR, b"SponsorFish", 50, ctx(&mut scenario));

        // Check supply and population
        assert!(fish::get_total_supply(&treasury_cap) == initial_supply + 300, 2);
        assert!(fish::get_total_population(&ecosystem_state) == initial_population + 1, 3);

        // Check USER2_ADDR received the sponsored fish with hype
        next_tx(&mut scenario, USER2_ADDR);
        let sponsored_fish = test_scenario::take_from_sender<FishMetadata>(&scenario);
        assert!(fish::get_fish_balance(&sponsored_fish) == 300, 4);
        let (name, _, _, hype, _, _) = fish::get_fish_details(&sponsored_fish);
        assert!(name == string::utf8(b"SponsorFish"), 5);
        assert!(hype == 50, 6);

        // Return objects
        test_scenario::return_to_sender(&scenario, sponsored_fish);
        test_scenario::return_shared(ecosystem_state);
        test_scenario::return_to_sender(&scenario, treasury_cap);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ::aquachain_contracts::fish::ENotAdminOrSponsor)]
    fun test_sponsor_mint_fail_not_sponsor() {
        let (mut scenario, mut treasury_cap, mut ecosystem_state) = setup_scenario();

        // USER1_ADDR (not a sponsor) tries to mint
        next_tx(&mut scenario, USER1_ADDR);
        fish::sponsor_mint_fish(&mut treasury_cap, &mut ecosystem_state, 100, USER1_ADDR, b"FailFish", 10, ctx(&mut scenario));

        // Cleanup (won't be reached)
        test_scenario::return_shared(ecosystem_state);
        test_scenario::return_to_sender(&scenario, treasury_cap);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ::aquachain_contracts::fish::EFeatureNotImplemented)]
    fun test_sponsor_create_token_type_aborts() {
         let (mut scenario, mut treasury_cap, mut ecosystem_state) = setup_scenario();

        // Register SPONSOR1_ADDR
        next_tx(&mut scenario, ADMIN_ADDR);
        fish::register_sponsor(&mut ecosystem_state, SPONSOR1_ADDR, ctx(&mut scenario));

        // SPONSOR1_ADDR tries to call the unimplemented function
        next_tx(&mut scenario, SPONSOR1_ADDR);
        fish::sponsor_create_token_type(&mut ecosystem_state, ctx(&mut scenario));

        // Cleanup (won't be reached)
        test_scenario::return_shared(ecosystem_state);
        test_scenario::return_to_sender(&scenario, treasury_cap);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_evolve_fish() {
        let (mut scenario, mut treasury_cap, mut ecosystem_state) = setup_scenario();

        // Mint a fish for USER1_ADDR
        next_tx(&mut scenario, ADMIN_ADDR);
        fish::mint(&mut treasury_cap, &mut ecosystem_state, 100, USER1_ADDR, b"Growlithe", ctx(&mut scenario));

        // USER1_ADDR takes the fish and increases hype to meet evolution criteria
        next_tx(&mut scenario, USER1_ADDR);
        let mut fish_metadata = test_scenario::take_from_sender<FishMetadata>(&scenario);

        // Grow to stage 3 (Adult)
        fish::increase_hype(&mut fish_metadata, 100, &ecosystem_state, ctx(&mut scenario)); // Stage 1
        fish::increase_hype(&mut fish_metadata, 200, &ecosystem_state, ctx(&mut scenario)); // Stage 2
        fish::increase_hype(&mut fish_metadata, 300, &ecosystem_state, ctx(&mut scenario)); // Stage 3

        // Add enough hype for evolution (threshold > 1000)
        fish::increase_hype(&mut fish_metadata, 1001, &ecosystem_state, ctx(&mut scenario));

        // Evolve the fish
        fish::evolve_fish(&mut fish_metadata, &ecosystem_state, ctx(&mut scenario));

        // Check evolution results
        let (name, _, stage, _, gen, _) = fish::get_fish_details(&fish_metadata);
        assert!(stage == 3, 1); // Stage remains 3
        assert!(gen == 1, 2); // Generation increased
        // Removed the string::ends_with check as it's not available and complex string ops are avoided in contract
        // assert!(string::ends_with(&name, &string::utf8(b"Evolved Growlithe")), 3); // Name changed check removed
        assert!(name == string::utf8(b"Growlithe"), 3); // Check name remains unchanged as per contract logic

        // Return objects
        test_scenario::return_to_sender(&scenario, fish_metadata);
        test_scenario::return_shared(ecosystem_state);
        test_scenario::return_to_sender(&scenario, treasury_cap);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ::aquachain_contracts::fish::EInvalidGrowthStage)]
    fun test_evolve_fail_wrong_stage() {
        let (mut scenario, mut treasury_cap, mut ecosystem_state) = setup_scenario();

        // Mint a fish for USER1_ADDR
        next_tx(&mut scenario, ADMIN_ADDR);
        fish::mint(&mut treasury_cap, &mut ecosystem_state, 100, USER1_ADDR, b"Magikarp", ctx(&mut scenario));

        // USER1_ADDR takes the fish (still stage 0)
        next_tx(&mut scenario, USER1_ADDR);
        let mut fish_metadata = test_scenario::take_from_sender<FishMetadata>(&scenario);

        // Try to evolve immediately (should fail)
        fish::evolve_fish(&mut fish_metadata, &ecosystem_state, ctx(&mut scenario));

        // Cleanup (won't be reached)
        test_scenario::return_to_sender(&scenario, fish_metadata);
        test_scenario::return_shared(ecosystem_state);
        test_scenario::return_to_sender(&scenario, treasury_cap);
        test_scenario::end(scenario);
    }

}

