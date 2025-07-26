package main

import (
	"fmt"
	"net/http"
)

func main() {
	// Create a file server that serves files from the "./static" directory
	fileServer := http.FileServer(http.Dir("./static"))

	// Handle all requests to "/" by serving files from our static directory
	http.Handle("/", fileServer)

	// Start the server on port 8080
	fmt.Println("Server starting on http://localhost:8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		fmt.Printf("Error starting server: %s\n", err)
	}
}
