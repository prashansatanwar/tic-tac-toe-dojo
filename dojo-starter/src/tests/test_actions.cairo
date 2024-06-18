#[cfg(test)]
mod tests {
    use starknet::class_hash::Felt252TryIntoClassHash;
    use starknet::ContractAddress;
    use starknet::testing::{set_contract_address};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};
    use dojo_starter::models::game::{game, Game, Board, BoardPosition};
    use dojo_starter::{
        systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}}
    };

    #[test]
    #[available_gas(300000000)]
    fn test_create_game() {
        let caller = starknet::contract_address_const::<0x1>();
        set_contract_address(caller);
        let mut models = array![game::TEST_CLASS_HASH];
        let world = spawn_test_world(models);
        let contract_address = world.deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap(), array![].span());
        let actions_system = IActionsDispatcher { contract_address };

        // Call create_game
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

    #[test]
    #[available_gas(300000000)]
    fn test_join_game() {
        let caller = starknet::contract_address_const::<0x1>();
        set_contract_address(caller);
        let mut models = array![game::TEST_CLASS_HASH];
        let world = spawn_test_world(models);
        let contract_address = world.deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap(), array![].span());
        let actions_system = IActionsDispatcher { contract_address };

        // Call create_game
        actions_system.create_game();

        // game state
        let mut game_state = get!(world, 0, (Game));

        // const_player
        let const_player = starknet::contract_address_const::<'const_player'>();

        assert_eq!(game_state.id, 0);

        assert_eq!(game_state.player1, const_player);
        assert_eq!(game_state.player2, const_player);

        // player 1
        let player1 = starknet::contract_address_const::<0x2>();
        set_contract_address(player1);

        // call join game
        actions_system.join_game(game_state.id);

        game_state = get!(world, 0, (Game));
        
        assert_eq!(game_state.player1, player1);
        assert_eq!(game_state.player2, const_player);

        // player 2
        let player2 = starknet::contract_address_const::<0x3>();
        set_contract_address(player2);

        // call join game
        actions_system.join_game(game_state.id);

        game_state = get!(world, 0, (Game));

        assert_eq!(game_state.player1, player1);
        assert_eq!(game_state.player2, player2);    
    }

    #[test]
    #[available_gas(300000000)]
    fn test_play_game() {
        let mut models = array![game::TEST_CLASS_HASH];
        let world = spawn_test_world(models);
        let contract_address = world.deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap(), array![].span());
        let actions_system = IActionsDispatcher { contract_address };

        // create game
        let caller = starknet::contract_address_const::<0x1>();
        set_contract_address(caller);
        actions_system.create_game();

        let mut game_state = get!(world, 0, (Game));

        // join players
        let player1 = starknet::contract_address_const::<0x2>();
        let player2 = starknet::contract_address_const::<0x3>();
        set_contract_address(player1);
        actions_system.join_game(game_state.id);
        set_contract_address(player2);
        actions_system.join_game(game_state.id);

        // play game

        let mut current_player = player1.clone();
        let move1 = BoardPosition{row: 1, col: 1};
        set_contract_address(current_player);
        actions_system.play_game(game_state.id, move1);

        let curr_board = Board {
            c00: 0,
            c01: 0,
            c02: 0,

            c10: 0,
            c11: 1,
            c12: 0,

            c20: 0,
            c21: 0,
            c22: 0
        };

        game_state = get!(world, 0, (Game));

        assert_eq!(game_state.board, curr_board);

        current_player = player2.clone();
        let move2 = BoardPosition{row:0, col:2};
        set_contract_address(current_player);
        actions_system.play_game(game_state.id, move2);

        let curr_board = Board {
            c00: 0,
            c01: 0,
            c02: 2,

            c10: 0,
            c11: 1,
            c12: 0,

            c20: 0,
            c21: 0,
            c22: 0
        };

        game_state = get!(world, 0, (Game));

        assert_eq!(game_state.board, curr_board);

    }

    #[test]
    #[available_gas(300000000)]
    fn test_win() {
        let mut models = array![game::TEST_CLASS_HASH];
        let world = spawn_test_world(models);
        let contract_address = world.deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap(), array![].span());
        let actions_system = IActionsDispatcher { contract_address };

        // create game
        let caller = starknet::contract_address_const::<0x1>();
        set_contract_address(caller);
        actions_system.create_game();

        let mut game_state = get!(world, 0, (Game));

        // join players
        let player1 = starknet::contract_address_const::<0x2>();
        let player2 = starknet::contract_address_const::<0x3>();
        set_contract_address(player1);
        actions_system.join_game(game_state.id);
        set_contract_address(player2);
        actions_system.join_game(game_state.id);


        // play
        set_contract_address(player1);
        actions_system.play_game(game_state.id, BoardPosition{row: 1, col: 1});
        set_contract_address(player2);
        actions_system.play_game(game_state.id, BoardPosition{row: 0, col: 0});
        set_contract_address(player1);
        actions_system.play_game(game_state.id, BoardPosition{row: 0, col: 2});
        set_contract_address(player2);
        actions_system.play_game(game_state.id, BoardPosition{row: 0, col: 1});
        set_contract_address(player1);
        actions_system.play_game(game_state.id, BoardPosition{row: 2, col: 0});

        game_state = get!(world, 0, (Game));
        
        assert_eq!(game_state.winner, player1);


    }

}