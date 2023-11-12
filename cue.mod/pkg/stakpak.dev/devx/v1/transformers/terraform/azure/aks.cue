package azure

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
	helpers "stakpak.dev/devx/v1/transformers/terraform/azure/helpers"
)

#AddKubernetesCluster: v1.#Transformer & {
	traits.#KubernetesCluster
	k8s: _
	k8s: version: major: 1
	k8s: version: minor: <=26 & >=24
	azure: {
		providerVersion:   string | *"3.69.0"
		location:          helpers.#Location
		resourceGroupName: string | *"k8s-rg"
		aks: {
			nodeSize:      string | *"Standard_D2_v2"
			minCount:      uint | *1
			maxCount:      uint | *3
			nodeAutoScale: bool | *true
			dnsPrefix:     string | *k8s.name
		}
		...
	}
	$resources: terraform: schema.#Terraform & {
		data: "azurerm_kubernetes_service_versions": "\(k8s.name)": {
			version_prefix: "\(k8s.version.major).\(k8s.version.minor)."
			location:       azure.location
		}
		terraform: {
			required_providers: {
				"azurerm": {
					source:  "hashicorp/azurerm"
					version: azure.providerVersion
				}
			}
		}
		provider: {
			"azurerm": {
				features: {}
			}
		}
		resource: {
			azurerm_resource_group: "\(k8s.name)-resource-group": {
				name:     azure.resourceGroupName
				location: azure.location
			}
			azurerm_kubernetes_cluster: "\(k8s.name)": {
				name:                k8s.name
				location:            azure.location
				resource_group_name: "${azurerm_resource_group.\(k8s.name)-resource-group.name}"
				kubernetes_version:  "${data.azurerm_kubernetes_service_versions.\(k8s.name).latest_version}"
				identity: {
					type: "SystemAssigned"
				}
				dns_prefix: azure.aks.dnsPrefix
				default_node_pool: {
					{
						name:                "workerpool1"
						vm_size:             azure.aks.nodeSize
						node_count:          azure.aks.minCount
						min_count:           azure.aks.minCount
						max_count:           azure.aks.maxCount
						enable_auto_scaling: azure.aks.nodeAutoScale
						tags: {
							"name": "workerpool1"
							source: "terraform"
						}
						temporary_name_for_rotation: "temppool1"
					}
				}

			}
		}
	}
}

#AddHelmProvider: v1.#Transformer & {
	traits.#Helm
	k8s: {
		name: string
		...
	}
	azure: {
		providerVersion:   string | *"3.69.0"
		resourceGroupName: string | *"k8s-rg"
		...
	}
	$resources: terraform: schema.#Terraform & {
		terraform: {
			required_providers: {
				"azurerm": {
					source:  "hashicorp/azurerm"
					version: azure.providerVersion
				}
			}
		}
		provider: {
			"azurerm": {
				features: {}
			}
		}
		data: azurerm_kubernetes_cluster: "\(k8s.name)": {
			name:                k8s.name
			resource_group_name: azure.resourceGroupName
		}
		provider: helm: kubernetes: {
			host:                   "${data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].host}"
			username:               "${data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].username}"
			password:               "${data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].password}"
			client_certificate:     "${base64decode(data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].client_certificate)}"
			client_key:             "${base64decode(data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].client_key)}"
			cluster_ca_certificate: "${base64decode(data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].cluster_ca_certificate)}"
		}
	}
}

#AddKubernetesProvider: v1.#Transformer & {
	k8s: {
		name: string
		...
	}
	azure: {
		providerVersion:   string | *"3.69.0"
		resourceGroupName: string | *"k8s-rg"
		...
	}
	$resources: terraform: schema.#Terraform & {
		terraform: {
			required_providers: {
				"azurerm": {
					source:  "hashicorp/azurerm"
					version: azure.providerVersion
				}
			}
		}
		provider: {
			"azurerm": {
				features: {}
			}
		}
		data: azurerm_kubernetes_cluster: "\(k8s.name)": {
			name:                k8s.name
			resource_group_name: azure.resourceGroupName
		}
		provider: kubernetes: {
			host:                   "${data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].host}"
			username:               "${data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].username}"
			password:               "${data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].password}"
			client_certificate:     "${base64decode(data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].client_certificate)}"
			client_key:             "${base64decode(data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].client_key)}"
			cluster_ca_certificate: "${base64decode(data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].cluster_ca_certificate)}"
		}
	}
}
