package components

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	"guku.io/devx/k8s/services/eso/resources"
)

#AWSSecretStore: {
	traits.#KubernetesResources
	secretStore: {
		name:             string
		namespace:        string
		region:           string
		scope:            "cluster" | "namespace"
		type:             "ParameterStore" | "SecretsManager"
		role?:            string
		accessKeySecret?: string | v1.#Secret
	}

	if secretStore.scope == "cluster" {
		k8sResources: "secret-store-\(secretStore.name)": resources.#ClusterSecretStore
	}
	if secretStore.scope == "namespace" {
		k8sResources: "secret-store-\(secretStore.name)": resources.#SecretStore & {
			metadata: namespace: secretStore.namespace
		}
	}
	k8sResources: "secret-store-\(secretStore.name)": {
		metadata: name: secretStore.name
		spec: provider: aws: {
			service: secretStore.type
			region:  secretStore.region
			if secretStore.role != _|_ {
				role: secretStore.role
			}
			if (secretStore.accessKeySecret & v1.#Secret) != _|_ {
				auth: secretRef: {
					accessKeyIDSecretRef: {
						namespace: secretStore.namespace
						name:      secretStore.accessKeySecret.name
						key:       "access-key"
					}
					secretAccessKeySecretRef: {
						namespace: secretStore.namespace
						name:      secretStore.accessKeySecret.name
						key:       "secret-access-key"
					}
				}
			}
		}
	}
}
