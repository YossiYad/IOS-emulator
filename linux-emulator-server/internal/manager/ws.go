package manager

import (
	"io"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{CheckOrigin: func(r *http.Request) bool { return true }}

func (m *Manager) LogsWSHandler(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		return
	}
	defer conn.Close()

	name := r.URL.Query().Get("name")
	if name == "" {
		conn.WriteMessage(websocket.TextMessage, []byte("name query param required"))
		return
	}
	filePath := "/var/log/silicon-emulator/" + name + ".log"

	// open file and stream new data
	var offset int64 = 0
	for {
		f, err := os.Open(filePath)
		if err != nil {
			conn.WriteMessage(websocket.TextMessage, []byte("waiting for log file..."))
			time.Sleep(1 * time.Second)
			continue
		}
		_, err = f.Seek(offset, io.SeekStart)
		if err != nil {
			f.Close()
			return
		}
		buf := make([]byte, 4096)
		n, err := f.Read(buf)
		if n > 0 {
			offset += int64(n)
			conn.WriteMessage(websocket.TextMessage, buf[:n])
		}
		f.Close()
		if err == io.EOF {
			time.Sleep(500 * time.Millisecond)
			continue
		}
		if err != nil {
			conn.WriteMessage(websocket.TextMessage, []byte("error reading log: "+err.Error()))
			return
		}
	}
}
