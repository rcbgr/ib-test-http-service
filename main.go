package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"log"
)

func main() {

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		io.WriteString(w, "Hello World\n")
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		io.WriteString(w, "ok\n")
	})


	port := "8443"

	if len(os.Getenv("PORT")) > 0 {
		port = os.Getenv("PORT")
	}

	fmt.Println(fmt.Sprintf("starting listener on: %s", port))

	if err := http.ListenAndServeTLS(fmt.Sprintf(":%s", port), "server.crt", "server.key", nil); err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
