package main

import (
	"log"
	"os"
	"strings"
)

const (
	chmod        = 0444 // TODO: custom mode
	secretPrefix = "secret_"
	secretsPath  = "/run/secrets/"
)

func main() {
	var errors int
	for _, kv := range os.Environ() {
		kv, ok := strings.CutPrefix(kv, secretPrefix)
		if !ok {
			continue
		}
		pair := strings.SplitN(kv, "=", 2)
		path := secretsPath + pair[0]
		err := os.WriteFile(path, []byte(pair[1]), chmod)
		if err != nil {
			log.Printf("error writing secret '%s': %v", pair[0], err)
			errors++
		}
		// os.Chown(path, 1000, 1000) TODO: custom uid/gid
	}
	os.Exit(errors)
}
