/*
* CS4710: Model-Driven Software Development, Spring 2020
* Computer Science Department Michigan Technological University
*
* Assignment: SPIN Group Assignment #1: PBYOR
*
* Authors: James Helm
*		   Kallen Marcavage
*
* Due Date: 2020-03-06
*/

#include "for.h"

#define Terminated (np_ == 0)

#define K 5
#define PLAYERS  K
#define N_CARDS 4
#define SHUFFLE_RATIO 2

// Cards "2d" array
// https://stackoverflow.com/questions/58744199/all-possible-knight-moving-on-a-chessboard-in-promela
// Each Player owns cards[(player * N_CARDS) - ((player * N_CARDS) + N_CARDS)]
byte cards[PLAYERS * N_CARDS];
#define CARDS(player, card_index) cards[(player) * N_CARDS + (card_index)]
#define IS_VALID_CARD(player, card_index) ((player) >= 0 && (card_index) >= 0 && (player) < PLAYERS && (card_index) < N_CARDS)


// LTL for eventually the game ends
//ltl term { <> Terminated }
// LTL for eventually there are 4 or more players
//ltl minPlayers { <> (PLAYERS > 3) }
// LTL ensuring that all players have the same top card
// Hardcoded to 4 players currently
ltl winCondition { <> Terminated && (CARDS(0,0) == CARDS(1,0) && CARDS(1,0) == CARDS(2,0) && CARDS(2,0) == CARDS(3,0) && CARDS(3,0) == CARDS(4,0))}

// Swap two card indicies of the players
inline swap(player,first_card, second_card) {
    assert(IS_VALID_CARD(player, first_card))
    assert(IS_VALID_CARD(player, second_card))
    int temp = CARDS(player, first_card); // set temp
    CARDS(player, first_card) = CARDS(player, second_card); // replace 1 with 2
    CARDS(player, second_card) = temp; // replace 2 with temp
}

// Shuffles all of the players card decks
inline shuffleDecks() {
    int numberOfShuffles = 0;

    // 127 => Max byte
    select(numberOfShuffles :  1..127);

    // Iterate over each player
    for (playerID, 0, PLAYERS - 1)
        // number of shuffles per player
        for (timeShuffle, 0, numberOfShuffles - 1)
            // Get two shuffle indexes
            byte card1;
            byte card2;
            // Select two values to shuffle
            // they could be the same value,but do we really care?
            select(card1: 0 .. (N_CARDS - 1));
            select(card2: 0 .. (N_CARDS - 1));
            // Swaps the cards
            swap(playerID, card1, card2);
        rof (timeShuffle)
    rof (playerID)
}

proctype Player(int player_ID){
    // Print player ID
    printf("player ID %d\n", player_ID);

    // Assign hold check
    byte checkHold = 0;

    // Get left player ID
    int LEFT_PLAYER = -1;
    if
    :: (player_ID == 0) -> LEFT_PLAYER = (PLAYERS - 1); // Edge case wrap
    :: else -> LEFT_PLAYER = (player_ID -1);
    fi
    printf("Player(%d): left player: %d\n",player_ID, LEFT_PLAYER );

    // Get right player ID
    int RIGHT_PLAYER = -1;
    if
    :: (player_ID == (PLAYERS-1)) -> RIGHT_PLAYER = 0; // Edge case wrap
    :: else -> RIGHT_PLAYER = (player_ID + 1);
    fi
    printf("Player(%d): right player: %d\n",player_ID, RIGHT_PLAYER );

    // Perform decision making stuff
    do
    // If we have held due to both sides being the same for N_CARDS turns, we assume win conditions
    // Each "Rule" is atomic, whether by atomic blokc or just a single assignment statement
    :: checkHold < (N_CARDS + 1) ->
        if
        :: CARDS(LEFT_PLAYER, 0) == CARDS(player_ID, 0) &&
           CARDS(RIGHT_PLAYER,0) == CARDS(player_ID, 0) ->
               // hold, aka do nothing, but increment
               checkHold = checkHold + 1
               skip;
        :: CARDS(LEFT_PLAYER,0) < CARDS(player_ID, 0) && CARDS(RIGHT_PLAYER, 0) < CARDS(player_ID, 0) ->
            // Both are lesser, so we'll swap as we're likely holding a large number
            atomic {
                swap(player_ID, 0, (N_CARDS - 1));
            }
            checkHold = 0;
        :: CARDS(LEFT_PLAYER,0) > CARDS(player_ID, 0) && CARDS(RIGHT_PLAYER,0) > CARDS(player_ID, 0) ->
            // Less than right but greater than left, swap
            atomic {
                swap(player_ID, 0, (N_CARDS - 1));
            }
            checkHold = 0;
        :: CARDS(LEFT_PLAYER,0) < CARDS(player_ID, 0) && CARDS(RIGHT_PLAYER,0) < CARDS(player_ID, 0) ->
            // Greater than right but less than left, hold
            skip;
            checkHold = 0;
        fi
    :: else -> break;
    od

    printf("Player(%d): ends game with top card: %d", player_ID, CARDS(player_ID, 0));
}

proctype Owner() {
    printf("owner %d\n", _pid);
    byte shuffles = 0;
    byte selected;

    /*
    Previously did select on % chance, but this made modeling
    incredibly difficult as select very rarely chose above 5.
    */
    select(selected: 1 .. SHUFFLE_RATIO);

    do
    :: shuffles < 30 -> // Specified 30 for search depth reduction
        if
        :: selected >= SHUFFLE_RATIO -> // Only shuffle if tails
            // Shuffle the decks
            atomic{shuffleDecks();}
            // Increment counter for finiteness
            shuffles = shuffles + 1;
            select(selected: 1..100);
        :: else -> select(selected: 1..100);
        fi
    :: else -> break;
    od
}

init {
    // Populate player's hands
    int cardValue
    for (player, 0, (PLAYERS - 1))
        for (cardIndex, 0, (N_CARDS - 1))
            assert(IS_VALID_CARD(player, cardIndex));
            CARDS(player,cardIndex) = cardIndex;
        rof (cardIndex)
    rof (player)
    // Shuffle decks
    atomic{ shuffleDecks() }

    // Start Owner and players
    atomic {
        run Owner();
        for (player_ID, 0, (PLAYERS - 1))
            run Player(player_ID);
        rof (player_ID)
    }
}
