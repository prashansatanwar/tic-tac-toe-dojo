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
    column: u8
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Game {
    #[key]
    id: u32,
    player1: ContractAddress,
    player2: ContractAddress,
    board: Board
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
            board: board
        }
    }

    fn join(mut game: Game, player: ContractAddress) -> Game {
        let const_player = starknet::contract_address_const::<'const_player'>();

        if(game.player1 == const_player) {
            game.player1 = player;
        }
        else {
            game.player2 = player;
        }

        game
    }

    fn play(mut game: Game, player: ContractAddress, position: BoardPosition) -> Game {
        let player_value: u8 = if player == game.player1 {1} else {2};

        
        match position.row {
            0 => match position.column {
                0 => game.board.c00 = player_value,
                1 => game.board.c01 = player_value,
                2 => game.board.c02 = player_value,
                _ => panic!("Invalid column: {}", position.column),
            },
            1 => match position.column {
                0 => game.board.c10 = player_value,
                1 => game.board.c11 = player_value,
                2 => game.board.c12 = player_value,
                _ => panic!("Invalid column: {}", position.column),
            },
            2 => match position.column {
                0 => game.board.c20 = player_value,
                1 => game.board.c21 = player_value,
                2 => game.board.c22 = player_value,
                _ => panic!("Invalid column: {}", position.column),
            },
            _ => panic!("Invalid row: {}", position.row),
        }

        game

    }
}
