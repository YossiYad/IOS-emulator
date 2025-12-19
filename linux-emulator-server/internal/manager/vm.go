package manager

import (
	"context"
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"sync"
	"time"
)

type VMState struct {
	Name      string    `json:"name"`
	PID       int       `json:"pid"`
	StartedAt time.Time `json:"started_at"`
	Cmd       *exec.Cmd `json:"-"`
}

type Manager struct {
	mu  sync.Mutex
	vms map[string]*VMState
}

func NewManager() *Manager {
	return &Manager{vms: make(map[string]*VMState)}
}

func (m *Manager) StartVM(ctx context.Context, name string, args []string) (*VMState, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if _, ok := m.vms[name]; ok {
		return nil, errors.New("vm already running")
	}

	// run the runner script
	runner := filepath.Join("/workspaces/silicon-M1-Apple-emulator/linux-emulator-server/src/scripts/enhanced-run.sh")
	cmdArgs := append([]string{runner, "--name", name}, args...)
	cmd := exec.CommandContext(ctx, "/bin/bash", cmdArgs...)
	// ensure logs directory exists
	_ = os.MkdirAll("/var/log/qemu-ios-emulator", 0o755)
	logFilePath := "/var/log/qemu-ios-emulator/" + name + ".log"
	f, err := os.OpenFile(logFilePath, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o644)
	if err == nil {
		cmd.Stdout = f
		cmd.Stderr = f
	}

	if err := cmd.Start(); err != nil {
		if f != nil {
			f.Close()
		}
		return nil, err
	}

	vs := &VMState{Name: name, PID: cmd.Process.Pid, StartedAt: time.Now(), Cmd: cmd}
	m.vms[name] = vs
	// monitor in background
	go func() {
		_ = cmd.Wait()
		if f != nil {
			f.Close()
		}
		m.mu.Lock()
		delete(m.vms, name)
		m.mu.Unlock()
	}()

	return vs, nil
}

func (m *Manager) StopVM(name string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	vs, ok := m.vms[name]
	if !ok {
		return errors.New("vm not found")
	}
	if vs.Cmd != nil && vs.Cmd.Process != nil {
		_ = vs.Cmd.Process.Kill()
		return nil
	}
	return errors.New("process not running")
}

func (m *Manager) ListVMs() []*VMState {
	m.mu.Lock()
	defer m.mu.Unlock()
	out := make([]*VMState, 0, len(m.vms))
	for _, v := range m.vms {
		out = append(out, v)
	}
	return out
}

func (m *Manager) GetVM(name string) (*VMState, bool) {
	m.mu.Lock()
	defer m.mu.Unlock()
	v, ok := m.vms[name]
	return v, ok
}
