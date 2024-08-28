variable "env" {
  type        = string
  description = "The deployment environment name, e.g., 'prod', 'dev', or 'test'."
}

variable "cluster_config" {
  type        = any
  description = "Configuration for the cluster, detailing specifics like size, type, and other cluster-related settings."
}

## ECR
variable "ecr_names" {
  type        = any
  description = "Names of the Elastic Container Registry repositories required for the deployment."
}

variable "vpc_id" {
  type = string
}