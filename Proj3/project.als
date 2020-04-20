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

// Class happens at least once in some timeslot.
// There is at least one class
fact classesHaveAtLeastOneTimeOccurence {
	some time:Time, class:Class | class.happens = time
}

fact studentsAreTakingClasses {
	some class:Class, student:Student | student.takes = class
}

// Relation: class is taken by students, and the
// 			 inverse relation pairs
fact unifyStudentTakingClassTakenbyRelation {
	all student:Student, class:Class |
		student in class.takenBy
}

fact unifyClassTakenByStudentTakesRelation {
	all class:Class, student:Student|
		class in student.takes
}

// Relation: class is taught by at least one professor,
//			 and the inverse relation pairs
fact unifyProfessorTeachingClassTakenbyRelation {
	all professor:Professor, class:Class |
		professor in class.taughtBy
}
fact unifyClassTakenByProfessorTeachingRelation {
	all class:Class, professor:Professor |
		class in professor.teaches
}

// Relation: class is taught by at least one professor,
//			 and the inverse relation pairs
fact unifyClassHappensTimeEventRelation {
	all class:Class, time:Time |
		class in time.event
}

fact unifyTimeEventClassHappensRelation {
	all time:Time, class:Class |
		time in class.happens
}


/* Predicates */
pred show {
}

run show for 12 Class, 10 Student, 6 Professor
