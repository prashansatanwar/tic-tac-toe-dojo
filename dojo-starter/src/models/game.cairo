use starknet::ContractAddress;

#[derive(Debug, PartialEq, Copy, Drop, Serde, Introspect)]
struct Board {
    c00: u8,
    c01: u8,
    c02: u8,

    c10: u8,
    c11: u8,
    c12: u8,

    c20: u8,
    c21: u8,
    c22: u8
}

#[derive(Copy, Drop, Serde, Introspect)]
struct BoardPosition {
    row: u8,
    col: u8
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Game {
    #[key]
    id: u32,
    player1: ContractAddress,
    player2: ContractAddress,
    winner: ContractAddress,
    board: Board
}

mod errors {
    const INVALID_MOVE: felt252 = 'Invalid move';
    const GAME_OVER: felt252 = 'Game Over';
    const PLAYERS_FULL: felt252 = 'Can not add more players';
    const PLAYERS_NEEDED: felt252 = 'Need more players';
}

#[generate_trait]
impl GameImpl of GameTrait {
    fn new(id: u32, host: ContractAddress) -> Game {
        let player = starknet::contract_address_const::<'const_player'>();
        let board = Board {
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

        Game {
            id: id,
            player1: player,
            player2: player,
            winner: player,
            board: board
        }
    }

    fn join(mut game: Game, player: ContractAddress) -> Game {
        let const_player = starknet::contract_address_const::<'const_player'>();
        assert((game.player1 == const_player || game.player2 == const_player), errors::PLAYERS_FULL);

        if(game.player1 == const_player) {
            game.player1 = player;
        }
        else {
            game.player2 = player;
        }

        game
    }

    fn play(mut game: Game, player: ContractAddress, position: BoardPosition) -> Game {
        let const_player = starknet::contract_address_const::<'const_player'>();
        assert((game.player1 != const_player && game.player2 != const_player), errors::PLAYERS_NEEDED);
        assert((game.winner == const_player), errors::GAME_OVER);

        let player_value: u8 = if player == game.player1 {1} else {2};
        
        match position.row {
            0 => match position.col {
                0 => game.board.c00 = player_value,
                1 => game.board.c01 = player_value,
                2 => game.board.c02 = player_value,
                _ => assert(false, errors::INVALID_MOVE)
            },
            1 => match position.col {
                0 => game.board.c10 = player_value,
                1 => game.board.c11 = player_value,
                2 => game.board.c12 = player_value,
                _ => assert(false, errors::INVALID_MOVE)
            },
            2 => match position.col {
                0 => game.board.c20 = player_value,
                1 => game.board.c21 = player_value,
                2 => game.board.c22 = player_value,
                _ => assert(false, errors::INVALID_MOVE)
            },
            _ => assert(false, errors::INVALID_MOVE)
        }


        let win = is_win(game.board);

        if(win) {
            game.winner = player;
        }

        game

    }
}

fn is_win(board: Board) -> bool {
    let mut x = board.c00;
    let mut y = board.c01;
    let mut z = board.c02;

    let mut res = is_win_helper(x,y,z);

    y = board.c10; z = board.c20;
    res = res || is_win_helper(x,y,z);

    x = board.c10; y = board.c11; z = board.c12;
    res = res || is_win_helper(x,y,z);

    x = board.c01; y = board.c11; z = board.c21;
    res = res || is_win_helper(x,y,z);

    x = board.c20; y = board.c21; z = board.c22;
    res = res || is_win_helper(x,y,z);

    x = board.c02; y = board.c12; z = board.c22;
    res = res || is_win_helper(x,y,z);

    x = board.c00; y = board.c11; z = board.c22;
    res = res || is_win_helper(x,y,z);

    x = board.c02; y = board.c11; z = board.c20;
    res = res || is_win_helper(x,y,z);

    res 

}

fn is_win_helper(x: u8, y:u8, z:u8) -> bool{
    if (x == 0 && y == 0 && z == 0) {
        return false;
    }

    if (x == y && y == z) {
        return true;
    }

    false
}