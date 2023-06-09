package main

import (
	"guku.io/devx/v2alpha1"
	"guku.io/devx/v2alpha1/environments"
	k8s "guku.io/devx/v1/transformers/kubernetes"
)

builders: v2alpha1.#Environments & {
	dev: environments.#Compose

	prod: {
		environments.#Kubernetes

		config: namespace: "whalesay"

		flows: {
			//"kubernetes/add-deployment": pipeline: [k8s.#AddDeployment]
			//"kubernetes/add-service": pipeline: [k8s.#AddService]
			//"kubernetes/add-volumes": pipeline: [k8s.#AddWorkloadVolumes]
			"kubernetes/add-labels": pipeline: [k8s.#AddLabels & {
				labels: {
					"team": "NX-GSS"
					"env":  "prod"
				}
			}]
		}
	}
}
