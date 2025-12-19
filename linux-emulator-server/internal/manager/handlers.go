package manager

import (
	"context"
	"encoding/json"
	"net/http"
	"time"
)

type StartReq struct {
	Name string   `json:"name"`
	Args []string `json:"args,omitempty"`
}

func (m *Manager) StartVMHandler(w http.ResponseWriter, r *http.Request) {
	var req StartReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	ctx := r.Context()
	// short timeout for starting
	ctx2, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	vs, err := m.StartVM(ctx2, req.Name, req.Args)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(vs)
}

type StopReq struct {
	Name string `json:"name"`
}

func (m *Manager) StopVMHandler(w http.ResponseWriter, r *http.Request) {
	var req StopReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	if err := m.StopVM(req.Name); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (m *Manager) StatusHandler(w http.ResponseWriter, r *http.Request) {
	name := r.URL.Query().Get("name")
	if name == "" {
		http.Error(w, "name required", http.StatusBadRequest)
		return
	}
	v, ok := m.GetVM(name)
	if !ok {
		http.Error(w, "not found", http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(v)
}

func (m *Manager) ListHandler(w http.ResponseWriter, r *http.Request) {
	list := m.ListVMs()
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(list)
}
