package main

import (
	"fmt"
	"io"
	"os"
)

func main() {
	printMe(os.Stdout, "It works!")
}

func printMe(w io.Writer, message string) {
	fmt.Fprintf(w, "%s\n", message)
}
