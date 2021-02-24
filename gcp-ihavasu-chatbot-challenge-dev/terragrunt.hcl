# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl", "${get_parent_terragrunt_dir()}/fallback.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl", "${get_parent_terragrunt_dir()}/fallback.hcl"))

  # Extract the variables we need for easy access
  project_name = local.account_vars.locals.project_name
  project_id   = local.account_vars.locals.project_id
  region       = local.account_vars.locals.default_region
}

remote_state {
  backend = "gcs"

  config = {
    project  = local.project_id
    location = local.region
    bucket   = format("terragrunt--%s--%s", local.project_id, local.region)
    prefix   = "${path_relative_to_include()}/terraform.tfstate"

    gcs_bucket_labels = {
      owner = local.project_name
      name  = "terragrunt"
      name  = format("terragrunt--%s--%s", local.project_id, local.region)
    }
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)
