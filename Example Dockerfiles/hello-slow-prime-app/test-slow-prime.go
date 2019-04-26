package main

import "log"

func slowHighestPrime(value int) int {
	var x int
	x = 2

	if value < 4 {
		value = 4
	}

	for i := 3; i <= value; i++ {
		var primeval bool
		primeval = true
		for j := 2; j < i; j++ {
			if i%j == 0 {
				primeval = false
			}
		}
		if primeval {
			x = i
		}
	}

	return x
}

func main() {
	log.Printf("%v", slowHighestPrime(20000))
}
