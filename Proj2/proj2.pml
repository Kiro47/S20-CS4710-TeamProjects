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

#define K 4
#define PLAYERS  K
#define N_CARDS 4

//ltl term { <> Terminated }
ltl minPlayers { [] (PLAYERS > 3) }


// Cards "2d" array
// https://stackoverflow.com/questions/58744199/all-possible-knight-moving-on-a-chessboard-in-promela
// Each Player owns cards[(player * N_CARDS) - ((player * N_CARDS) + N_CARDS)]
byte cards[PLAYERS * N_CARDS];
#define CARDS(player, card_index) cards[(player) * N_CARDS + (card_index)]
#define IS_VALID_CARD(player, card_index) ((player) >= 0 && (card_index) >= 0 && (player) < PLAYERS && (card_index) < N_CARDS)


proctype Player(){
    printf("player %d\n)", _pid);
}

proctype Owner() {
    printf("owner %d\n", _pid);
}

init {
    // Populate player's hands
    int cardValue
    for (player, 0, (PLAYERS - 1))
        for (cardIndex, 0, (N_CARDS - 1))
            // This select statement is filling them, but not in the way we want
            // we'll need to figure out how to select population values better
            select(cardValue : 0 .. (N_CARDS - 1));
            assert(IS_VALID_CARD(player, cardIndex));
            CARDS(player,cardIndex) = cardValue;
        rof (cardIndex)
    rof (player)
}
