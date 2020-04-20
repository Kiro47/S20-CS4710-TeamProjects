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

// Relation: class is taken by students
fact unifyStudentTakingClassTakenbyRelation {
	all student:Student, class:Class |
		student in class.takenBy
}

fact unifyProfessorTeachingClassTakenbyRelation {
	all professor:Professor, class:Class |
		professor in class.taughtBy
}



/* Predicates */
pred show {}



run show
