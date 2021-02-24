# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# https://github.com/gruntwork-io/terragrunt/
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # https://github.com/ihavasu/infra-modules/tree/main/gcp/gke/public-cluster"
  source = "git::git@github.com:ihavasu/infra-modules/gcp/gke/public-cluster"
}

include {
  path = find_in_parent_folders()
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  env          = local.environment_vars.locals.environment
  cluster_name = "${local.env}-uswe1a-cc"
}

inputs = {
  location     = "us-west1-a"
  cluster_name = local.cluster_name

  cluster_service_account_name        = "${local.cluster_name}-sa"
  cluster_service_account_description = "GKE Cluster Service Account managed by Terraform for ${local.cluster_name}"

  vpc_cidr_block           = "10.42.0.0/16"
  vpc_secondary_cidr_block = "10.54.0.0/16"

  enable_vertical_pod_autoscaling = false

  service_account_roles = ["roles/dns.admin"]

  cluster_resource_labels = {
    environment = local.env
  }
}
