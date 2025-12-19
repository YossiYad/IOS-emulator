package ide

import (
	"encoding/json"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
)

var ProjectRoot = "/workspaces"

type FileEntry struct {
	Path  string `json:"path"`
	IsDir bool   `json:"is_dir"`
}

func ListHandler(w http.ResponseWriter, r *http.Request) {
	root := r.URL.Query().Get("root")
	if root == "" {
		root = ProjectRoot
	}
	entries := []FileEntry{}
	filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return nil
		}
		entries = append(entries, FileEntry{Path: path, IsDir: info.IsDir()})
		return nil
	})
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(entries)
}

func ReadHandler(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Query().Get("path")
	if path == "" {
		http.Error(w, "path required", http.StatusBadRequest)
		return
	}
	f, err := os.Open(path)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	defer f.Close()
	w.Header().Set("Content-Type", "application/octet-stream")
	io.Copy(w, f)
}

func WriteHandler(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Query().Get("path")
	if path == "" {
		http.Error(w, "path required", http.StatusBadRequest)
		return
	}
	os.MkdirAll(filepath.Dir(path), 0o755)
	f, err := os.Create(path)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer f.Close()
	_, err = io.Copy(f, r.Body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

type BuildReq struct {
	Path string `json:"path"`
	Out  string `json:"out"`
}

func BuildHandler(w http.ResponseWriter, r *http.Request) {
	var req BuildReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	// Attempt to invoke swiftc if available, else use clang for ObjC
	if _, err := exec.LookPath("swiftc"); err == nil {
		cmd := exec.Command("swiftc", "-o", req.Out, req.Path)
		out, err := cmd.CombinedOutput()
		if err != nil {
			http.Error(w, string(out), http.StatusInternalServerError)
			return
		}
		w.Write([]byte("built: " + req.Out))
		return
	}
	if _, err := exec.LookPath("clang"); err == nil {
		cmd := exec.Command("clang",
			"-o", req.Out, req.Path, "-ObjC", "-framework", "Foundation")
		out, err := cmd.CombinedOutput()
		if err != nil {
			http.Error(w, string(out), http.StatusInternalServerError)
			return
		}
		w.Write([]byte("built: " + req.Out))
		return
	}
	http.Error(w, "no compiler found (swiftc or clang)", http.StatusInternalServerError)
}
