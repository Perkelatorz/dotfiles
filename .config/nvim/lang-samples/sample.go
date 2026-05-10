package main

import "fmt"

func main() {
	fmt.Println(greet("nvim"))
}

func greet(name string) string {
	return "Hello, " + name + "!"
}
