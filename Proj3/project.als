// Project 

abstract sig Time {}

lone sig eightToNine, nineToTen, tenToEleven, 
	elevenToTwelve, twelveToOne, oneToTwo, twoToThree,
	threeToFour, fourToFive, fiveToSix extends Time {}

sig Class {
	happens: one Time,
	taughtBy: Professor,
	takenBy: Student
}

sig Student {
	takes: some Class
}

sig Professor {
	teaches: some Class
}




pred show {}

run show
