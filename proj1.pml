

#define N 5
#define N_PROCS 3

bool mutexes[N];

chan channels = [N] of {byte};

byte array[N];

proctype RandomNumber() {
    byte nr; // Pick random value
    do
    :: nr++ // randomly increment
    :: nr-- // randomly decrement
    :: break // Stop
    od;

    // Possible value
    byte i = nr % N;

    // Send back to swapper

}

/*
 * TODO: RNG will probably be a hell of a lot easier just copy and pasting in,
 *       functioning it in, seems to just cause dumb headaches.
 */


proctype Swapper() {
    // Decide position 1 to swap
    /* RNG */
    // Check lock for position 1
    // If no lock acquire

    // Decide position 2 to swap
    /* RNG */
    // Check lock for position 2
    // If no lock acquire

    // Swap Position 1 and Position 2

    // Release Position 1 and 2 locks
    // Exit
    printf("pid: %d\n", _pid);
}

init {
    byte i;
    // Init mutexes
    for (i : 0 .. (N - 1)) {
        mutexes[i] = false;
    }
    // Init Array
    for (i : 0 .. (N - 1)) {
        array[i] = i;
    }
    // Launch processes N times
    atomic {
        for (i : 1 .. N_PROCS) {
            run Swapper ();
        }
    }
}
