//Deprecated: in favor of universe.dagger.io/alpha package
package yarn

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"

	"universe.dagger.io/docker"
)

// Tests for the yarn package, grouped together in a reusable action.
#Tests: {
	// Test data, packaged alongside this cue file
	data: {
		contents: _load.output

		_load: core.#Source & {
			path: "./data/foo"
		}
	}

	// Run yarn.#Build
	simple: {
		build: #Build & {
			source: data.contents
		}

		verify: #AssertFile & {
			input:    build.output
			path:     "test"
			contents: "output\n"
		}
	}

	// Run yarn.#Build with a custom project name
	customName: {
		build: #Build & {
			project: "My Build"
			source:  data.contents
		}
		verify: #AssertFile & {
			input:    build.output
			path:     "test"
			contents: "output\n"
		}
	}

	// Run yarn.#Build with a custom docker image
	customImage: {
		buildImage: docker.#Build & {
			steps: [
				docker.#Pull & {
					source: "alpine"
				},
				docker.#Run & {
					command: {
						name: "apk"
						args: ["add", "yarn", "bash"]
					}
				},
			]
		}

		image: build.output

		build: #Build & {
			source: data.contents
			container: input: buildImage.output
		}
	}
}

// Make an assertion on the contents of a file
#AssertFile: {
	input:    dagger.#FS
	path:     string
	contents: string

	_read: core.#ReadFile & {
		"input": input
		"path":  path
	}

	actual: _read.contents

	// Assertion
	contents: actual
}

dagger.#Plan & {
	actions: test: #Tests
}
