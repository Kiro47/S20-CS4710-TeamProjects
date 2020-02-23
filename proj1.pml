#define pInCS (P@CS)
#define qInCS (Q@CS)

#define pTrying	(P@TS)
#define qTrying	(Q@TS)

//#define mutex (!(pInCS && qInCS))
#define mutex (procCount <= 1)
#define progress4P (pTrying -> <> pInCS)
#define progress4Q (qTrying -> <> qInCS)

#define Terminated (np_ == 0)

ltl safety { [] mutex }
//ltl safety { ![] mutex }

//ltl progP { [] progress4P }
//ltl progQ { [] progress4Q } 

//ltl term { <> Terminated }
//ltl term { <> Terminated }

#define N 5
byte array[N] = { 1, 2, 3, 4, 5 }

bool locked = false;
int procCount = 0;

active [N] proctype P(){
	
	byte nr;	/* pick random value  */
	do
	:: nr++		/* randomly increment */
	:: nr--		/* or decrement       */
	:: break	/* or stop            */
	od;

	/* Assign i and j values */
    int i = _pid;
    int j = nr % N;

	/* -------- Entry (Lock) -------- */
	atomic {
        (locked == false) -> locked = true; procCount++;
    }

	/* -------- Critical Section -------- */
    printf("Proc(%d) has entered the critical section\n", _pid);

    assert(procCount == 1); /* Ensure mutual exclusion */
    
    printf("Proc(%d) swapping array[%d] = %d and array[%d] = %d\n", _pid, i, array[i], j, array[j]);

    /* Swap the numbers -- NOT atomic */
    int temp = array[i];
    array[i] = array[j];
    array[j] = temp;
    /* -------- Critical Section -------- */

	/* -------- Exit (Unlock) -------- */
    atomic {
		locked = false; procCount--;
	}
}
