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

/* Functions */
fun getStudentProfessors (student:Student): set Professor {
	student.takes.*taughtBy
}

fun getProfessorStudents (professor:Professor): set Student {
	professor.teaches.*takenBy
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
/* Assertions */
assert studentsHaveProfessors {
	all student:Student |
		some #student.takes.taughtBy
}

assert professorsHaveClassTime {
	all professor:Professor |
		some #professor.teaches.happens
}

assert noStudentsWithoutClasses {
	all student:Student |
		no #student.takes
}

/* Predicates */
pred show {

}

// Many being 5 in our case
pred classesWithManyStudents (class:Class) {
	#class.takenBy >= 5
}

pred multipleClasses (classes:Class) {
	#classes.happens > 1
}

//run multipleClasses
run classesWithManyStudents for 5 Class, 10 Student, 3 Professor, 4 Time
