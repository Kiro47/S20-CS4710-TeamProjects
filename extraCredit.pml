/*
* CS4710: Model-Driven Software Development, Spring 2020
* Computer Science Department Michigan Technological University
*
* Assignment: SPIN Group Assignment #1: Extra Credit
* 
* Authors: Tyler Marenger
*		   James Helm
*
* Due Date: 2/25/20
*/

#include "for.h"

#define pInCS (P@CS)
#define qInCS (Q@CS)

#define pTrying	(P@TS)
#define qTrying	(Q@TS)

//#define mutex (!(pInCS && qInCS))
#define mutex ((procCount[0] <= 1) && (procCount[1] <= 1) && (procCount[2] <= 1) && (procCount[3] <= 1) && (procCount[4] <= 1))
#define distinctNumbers (array[0] != array[1] && array[1] != array[2] && array[0] != array[2] )
#define swapOccursConcur (concurrentCount <= 1)
#define noneZeroArrayElements (array[0] != 0 && array[1] != 0 && array[2] != 0)

#define progress4P (pTrying -> <> pInCS)
#define progress4Q (qTrying -> <> qInCS)

#define Terminated (np_ == 0)

//ltl safety { [] mutex }
//ltl safety { ![] mutex }

//ltl progP { [] progress4P }
//ltl progQ { [] progress4Q } 

//ltl term { <> Terminated }

//ltl concurrency { [] swapOccursConcur} /* Want to fail */

//ltl successfulSwap { [] (Terminated -> distinctNumbers) && <> Terminated }

#define N 5

byte array[N]; /* Number array */
int distinct[N];
byte arrayIndexLocks[N]; /* Index lock array */
byte procCount[N]; /* Process at index count array */
int turn = 0; /* Proccess turn */
int concurrentCount = 0;
int j;

[N] proctype swapProcess(){
    
    int i = _pid;
    
    NTS: printf("Entering noncritical section\n");
    
    /* Random Number Generator */
	/* Choose value between 0 and N-1 and stores in j */
    select(j : 0  ..  (N-1));

	/* -------- Entry (Lock) -------- */
	atomic {
	do
	:: turn != 0 
	::	/* Checks if the index is locked */
		if 
		:: turn == 0 && arrayIndexLocks[i] == 1 && arrayIndexLocks[j] == 1 && procCount[i] == 0 && procCount[j] == 0 ->
				turn = 1;

				/* Lock index */
				arrayIndexLocks[i] = 0;
				arrayIndexLocks[j] = 0;
 				
				if
				:: (i == j) -> 
						procCount[i]++;
						goto SKIP;
				fi;

				/* Process in critical section */
				procCount[i]++; 
				procCount[j]++;
				
    			SKIP:

				turn = 0;
			
				if
				:: (i != j) ->
						/* Check that only one process is in critical section */
						assert(procCount[i] <= 1 && procCount[j] <=1);
				fi;

				break;
		:: else -> 
					turn = 1;
					printf("arrayIndexLocks[%d] or arrayIndexLocks[%d] is being used\n", i, j);
					turn = 0;
		fi;
	od;
	}

	/* -------- Critical Section -------- */
    printf("Proc(%d) has entered the critical section\n", _pid);
	concurrentCount++;

	if
	:: (i != j) ->
			assert(procCount[i] <= 1 && procCount[j] <=1); /* Ensure mutual exclusion */
	fi;
	
    printf("Proc(%d) swapping array[%d] = %d and array[%d] = %d\n", _pid, i, array[i], j, array[j]);

    /* Swap the numbers operation -- NOT atomic */
    int temp = array[i];
    array[i] = array[j];
    array[j] = temp;
    /* -------- Critical Section -------- */

	/* -------- Exit (Unlock Array Indices) -------- */
   atomic { 
	   arrayIndexLocks[i] = 1; arrayIndexLocks[j] = 1; 
	   
	   /* Process in critical section */
	   procCount[i]--; 
	   procCount[j]--;
	
	   concurrentCount--;

	    if
		:: (i != j) ->
				assert(procCount[i] <= 1 && procCount[j] <=1); /* Ensure mutual exclusion */
		fi;
	}
    progress: goto NTS;
}

init {
    
	/* for(int k = 0; k < N-1; k++) */
	for (k, 0, N-1)

		arrayIndexLocks[k] = 1; // Load arrayIndexLocks with 1 to show not taken
		procCount[k] = 0; // Counts number of processes manipulating an index
		array[k] = k + 1; // Load array with values of i+1

	rof (k)

    run swapProcess();
}
