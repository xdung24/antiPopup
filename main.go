package main

import (
	"log"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
)

var htmlpage = []byte(`<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<script type="text/javascript">
    function startTimer(duration, display) {
		var timer = duration, minutes, seconds;
		var id = setInterval(function () {
			minutes = parseInt(timer / 60, 10);
			seconds = parseInt(timer % 60, 10);

			minutes = minutes < 10 ? "0" + minutes : minutes;
			seconds = seconds < 10 ? "0" + seconds : seconds;

			display.textContent = minutes + ":" + seconds;

			if (--timer < 0) {
				clearInterval(id);
				window.close();
			}
		}, 1000);
	}
	</script>
</head>
<body>
    <div>New tab ads is closing in <span id="time">00:00</span> second(s)!</div>
	<script type="text/javascript">
    window.onload = function () {
		startTimer(5, document.querySelector('#time'));
    };
	</script>
</body>
</html>`)

func redirectPage(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.WriteHeader(200)
	w.Write(htmlpage)
}

func certPath() string {
	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		return ""
	}
	return dir
}

func serveHttp() {
	log.Println("Serving http server")
	err := http.ListenAndServe(":80", nil)
	if err != nil {
		log.Fatal("ListenAndServe http: ", err)
	}
}

func serveHttps(certpath string) {
	log.Println("Serving https server")
	err := http.ListenAndServeTLS(":443", filepath.Join(certpath, "server.crt"), filepath.Join(certpath, "server.key"), nil)
	if err != nil {
		log.Fatal("ListenAndServe https: ", err)
	}
}

func main() {
	certpath := filepath.Join(certPath(), "certs")
	log.Println("Cert path: " + certpath)
	http.HandleFunc("/", redirectPage)
	go serveHttp()
	go serveHttps(certpath)
	// Wait for a signal to quit:
	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, os.Interrupt, os.Kill)
	<-signalChan
	log.Println("Gracefully shutting down")
}
