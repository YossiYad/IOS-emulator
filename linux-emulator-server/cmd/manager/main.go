package main

import (
	"log"
	"net/http"
	"os"

	ide "silicon-emulator/internal/ide"
	manager "silicon-emulator/internal/manager"

	"github.com/gorilla/mux"
)

func main() {
	port := os.Getenv("MANAGER_PORT")
	if port == "" {
		port = "8080"
	}

	m := manager.NewManager()

	r := mux.NewRouter()
	r.HandleFunc("/api/v1/vm/start", m.StartVMHandler).Methods("POST")
	r.HandleFunc("/api/v1/vm/stop", m.StopVMHandler).Methods("POST")
	r.HandleFunc("/api/v1/vm/status", m.StatusHandler).Methods("GET")
	r.HandleFunc("/api/v1/vm/list", m.ListHandler).Methods("GET")
	r.HandleFunc("/api/v1/ws/logs", m.LogsWSHandler)
	// IDE endpoints
	r.HandleFunc("/api/v1/ide/list", func(w http.ResponseWriter, r *http.Request) { ide.ListHandler(w, r) }).Methods("GET")
	r.HandleFunc("/api/v1/ide/read", func(w http.ResponseWriter, r *http.Request) { ide.ReadHandler(w, r) }).Methods("GET")
	r.HandleFunc("/api/v1/ide/write", func(w http.ResponseWriter, r *http.Request) { ide.WriteHandler(w, r) }).Methods("POST")
	r.HandleFunc("/api/v1/ide/build", func(w http.ResponseWriter, r *http.Request) { ide.BuildHandler(w, r) }).Methods("POST")

	// Serve the static web UI (if built)
	staticDir := "/workspaces/silicon-M1-Apple-emulator/linux-emulator-server/src/ui/web/build"
	if _, err := os.Stat(staticDir); err == nil {
		r.PathPrefix("/").Handler(http.FileServer(http.Dir(staticDir)))
	}

	srv := &http.Server{
		Addr:    ":" + port,
		Handler: r,
	}

	log.Printf("Manager API listening on %s", srv.Addr)
	log.Fatal(srv.ListenAndServe())
}
