package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	i := 0
	target, _ := strconv.Atoi(os.Args[1])
	for i < target {
		i++
	}
	fmt.Println(i)
}
