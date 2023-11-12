package main

import (
	"stakpak.dev/devx/v2alpha1"
	"stakpak.dev/devx/v2alpha1/environments"
	k8s "stakpak.dev/devx/v1/transformers/kubernetes"
)

builders: v2alpha1.#Environments & {
	dev: environments.#Compose & {
		drivers: compose: output: file: "docker-compose.yaml"
	}

	prod: {
		environments.#Kubernetes

		config: namespace: "whalesay"

		flows: {
			//"kubernetes/add-deployment": pipeline: [k8s.#AddDeployment]
			//"kubernetes/add-service": pipeline: [k8s.#AddService]
			//"kubernetes/add-volumes": pipeline: [k8s.#AddWorkloadVolumes]
			"kubernetes/add-labels": pipeline: [k8s.#AddLabels & {
				labels: {
					"team": "example-team"
					"env":  "prod"
				}
			}]
		}
	}
}
