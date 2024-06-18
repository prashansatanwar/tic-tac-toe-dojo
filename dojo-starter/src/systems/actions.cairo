use dojo_starter::models::game::{Game, BoardPosition};

// define the interface
#[dojo::interface]
trait IActions {
    fn create_game(ref world: IWorldDispatcher);
    fn join_game(ref world: IWorldDispatcher, game_id: u32);
    fn play_game(ref world: IWorldDispatcher, game_id: u32, pos: BoardPosition);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::game::{Game, GameTrait, BoardPosition};
    
    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn create_game(ref world: IWorldDispatcher) {
            let game_id = world.uuid();
            let caller = get_caller_address();

            let mut game = GameTrait::new(game_id, caller);

            set!(world, (game))
        }

        fn join_game(ref world: IWorldDispatcher, game_id: u32) {
            let caller = get_caller_address();

            let mut game = get!(world, game_id, (Game));
            
            game = GameTrait::join(game, caller);

            set!(world, (game));
        }

        fn play_game(ref world: IWorldDispatcher, game_id:u32 , pos: BoardPosition) {
            let caller = get_caller_address();

            let mut game = get!(world, game_id, (Game));

            game = GameTrait::play(game, caller, pos);

            set!(world, (game));
        }
        
    }
}
