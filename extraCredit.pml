#include "for.h"

#define pInCS (P@CS)
#define qInCS (Q@CS)

#define pTrying	(P@TS)
#define qTrying	(Q@TS)

//#define mutex (!(pInCS && qInCS))
#define mutex ((procCount[0] <= 1) && (procCount[1] <= 1) && (procCount[2] <= 1) && (procCount[3] <= 1) && (procCount[4] <= 1))
#define swapOccursConcur (concurrentCount > 1);
#define progress4P (pTrying -> <> pInCS)
#define progress4Q (qTrying -> <> qInCS)

#define Terminated (_nr_pr == 0)

//ltl safety { [] mutex }
//ltl safety { ![] mutex }

//ltl progP { [] progress4P }
//ltl progQ { [] progress4Q } 

ltl term { <> Terminated }

//ltl concurrency { [] !swapOccursConcur} /* Want to fail */

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
	:: 
			/* Checks if the index is locked */
			if 
			:: arrayIndexLocks[i] == 1 && arrayIndexLocks[j] == 1 && turn == 0 && procCount[i] == 0 && procCount[j] == 0 && i != j ->
				atomic {
                turn = 1;

				/* Lock index */
				arrayIndexLocks[i] = 0;
				arrayIndexLocks[j] = 0;
 				
				/* Process in critical section */
				procCount[i] = 1; 
				procCount[j] = 1;
                
				turn = 0;
			
				/* Check that only one process is in critical section */
				assert(procCount[i] <= 1 && procCount[j] <= 1);
                }
				break;
			:: else -> 
                atomic {
					if
					:: (i == j) -> select(j : 0  ..  N-1); break;
					fi;

					turn = 1;
					printf("arrayIndexLocks[%d] or arrayIndexLocks[%d] is being used\n", i, j);
					turn = 0;
                }
			fi;
		
	od;
    }

	/* -------- Critical Section -------- */
    printf("Proc(%d) has entered the critical section\n", _pid);
	concurrentCount++;

    assert(procCount[i] <= 1 && procCount[j] <=1); /* Ensure mutual exclusion */
	
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
	   procCount[i] = 0; 
	   procCount[j] = 0;
	
	   concurrentCount--;

	   assert(procCount[i] <= 1 && procCount[j] <=1);
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
