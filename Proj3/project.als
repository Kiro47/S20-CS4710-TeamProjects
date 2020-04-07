// Project


/* Signatures */
abstract sig Time {
	event: set Class
}

lone sig eightToNine, nineToTen, tenToEleven,
	elevenToTwelve, twelveToOne, oneToTwo, twoToThree,
	threeToFour, fourToFive, fiveToSix extends Time {}

sig Class {
	happens: some Time,
	taughtBy: some Professor,
	takenBy: some Student
}

sig Student {
	takes: some Class
}

sig Professor {
	teaches: some Class
}


/* Facts */

fact timeToClass {
	some time:Time, class:Class | class.happens = time
}


//fact

fact classesHaveAtLeastOneTimeOccurence {
	some time:Time, class:Class | class.happens = time
}

fact studentsAreTakingClasses {
	some class:Class, student:Student | student.takes = class
}

fact unifyStudentTakingClassTakenbyRelation {
/*
TODO: Once this is in proper working order, a very
similar relation can happen for prof to classes
*/
	// TODO: "works" but only giving us one student
	all student:Student, class:Class | class.takenBy = student
}


fact noEmptyTimeSlots {
	// TODO:  Only gives one time
	all time:Time, class:Class | class.happens = time
}

/* Predicates */
pred show {}



run show
