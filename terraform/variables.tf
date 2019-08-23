variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in mattermost should be provisioned"
}

variable "client_id" {
  description = "The Client ID for the Service Principal"
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal"
}

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID"
}

variable "machine_type" {
  description = "VM type for this Managed Kubernetes Cluster"
}
