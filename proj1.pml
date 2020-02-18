#define pInCS (P@CS)
#define qInCS (Q@CS)

#define pTrying	(P@TS)
#define qTrying	(Q@TS)

#define mutex (!(pInCS && qInCS))
#define progress4P (pTrying -> <> pInCS)
#define progress4Q (qTrying -> <> qInCS)

#define Terminated (np_ == 0)

#define N 5

//ltl safety { [] mutex }
//ltl progP { [] progress4P }
//ltl progQ { [] progress4Q } 
ltl term { <> Terminated }

byte array[N] = { 1, 2, 3, 4, 5 }

bool wantP = false, wantQ = false;
int turn = 0;


/* Random Number Generator */
active [N] proctype P(){

	byte nr;	/* pick random value  */
	do
	:: nr++		/* randomly increment */
	:: nr--		/* or decrement       */
	:: break	/* or stop            */
	od;

	byte nr2;	/* pick random value  */
	do
	:: nr2++	/* randomly increment */
	:: nr2--	/* or decrement       */
	:: break	/* or stop            */
	od;

	byte i = nr % N;
	byte j = nr2 % N;

	/* Swap */
	byte temp = array[i];
	array[i] = array[j];
	array[j] = temp;
}


/* Semaphore Emulation */
#define p	0
#define v	1

chan sema = [0] of { bit };

proctype dijkstra()
{	byte count = 1;

	do
	:: (count == 1) ->
		sema!p; count = 0
	:: (count == 0) ->
		sema?v; count = 1
	od
}

proctype user()
{	do
	:: sema?p;
		printf("Critical %d\n", _pid)
	   /*     critical section */
	   sema!v;
		printf("Non Criticial %d\n", _pid)
	   /* non-critical section */
	od
}

