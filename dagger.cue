package todoapp

import (
	"dagger.io/dagger"

	"universe.dagger.io/go"
)

dagger.#Plan & {
    client: filesystem: ".": read: contents: dagger.#FS

    actions: {
        test: go.#Test & {
            source: client.filesystem.".".read.contents
            packages: ["./..."]
        }

        build: go.#Build & {
            source: client.filesystem.".".read.contents
            packages:["./cmd/dummy"]
        }
    }

}