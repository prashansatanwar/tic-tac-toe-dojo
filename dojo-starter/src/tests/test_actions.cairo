#[cfg(test)]
mod tests {
    use starknet::class_hash::Felt252TryIntoClassHash;
    use starknet::ContractAddress;
    use starknet::testing::{set_contract_address};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};
    use dojo_starter::models::game::{game, Game, Board};
    use dojo_starter::{
        systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}}
    };

    #[test]
    #[available_gas(30000000)]
    fn test_create_game() {
        let caller = starknet::contract_address_const::<0x1>();
        set_contract_address(caller);
        let mut models = array![game::TEST_CLASS_HASH];
        let world = spawn_test_world(models);
        let contract_address = world.deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap(), array![].span());
        let actions_system = IActionsDispatcher { contract_address };

        // Call start_game
        actions_system.create_game();


        let game_state = get!(world, 0, (Game));

        let const_player = starknet::contract_address_const::<'const_player'>();
        let initial_board = Board {
            c00: 0,
            c01: 0,
            c02: 0,

            c10: 0,
            c11: 0,
            c12: 0,

            c20: 0,
            c21: 0,
            c22: 0
        };

        assert_eq!(game_state.id, 0);
        assert_eq!(game_state.player1, const_player);
        assert_eq!(game_state.player2, const_player);
        assert_eq!(game_state.board, initial_board);
    }

    fn test_join_game() {

    }


}