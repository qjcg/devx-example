package main

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

stack: v1.#Stack & {
	components: {

		whalesay: {
			traits.#Workload

			containers: default: {
				image: "vnovoselskiy/whalesay"
				command: ["cowsay"]
				args: ["Hello DevX!"]
				env: {
					API_KEY: string @guku(generate)
				}
			}
		}
	}
}
