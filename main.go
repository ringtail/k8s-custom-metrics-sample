package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

/**
	define metrics with different route label
 */
var (
	qpsTotal = promauto.NewGauge(prometheus.GaugeOpts{
		Name: "http_qps",
		Help: "The number of HTTP requests on / served in the last second",
		ConstLabels: map[string]string{
			"route": "/",
		},
	})

	qpsHome = promauto.NewGauge(prometheus.GaugeOpts{
		Name: "http_qps",
		Help: "The number of HTTP requests on / served in the last second",
		ConstLabels: map[string]string{
			"route": "/home",
		},
	})
)

func main() {

	initQPSLoop()

	http.Handle("/metrics", promhttp.Handler())

	http.HandleFunc("/", handler)
	http.HandleFunc("/home", homeHandler)

	http.ListenAndServe(":8080", nil)
}

/**
	init qps loop and reset every 1s.
 */
func initQPSLoop() {
	go func() {
		for {
			qpsTotal.Set(0)
			qpsHome.Set(0)
			time.Sleep(1 * time.Second)
		}
	}()
}

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello from '/' path!")
	qpsTotal.Inc()
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello from '/home' path!")
	qpsHome.Inc()
}
