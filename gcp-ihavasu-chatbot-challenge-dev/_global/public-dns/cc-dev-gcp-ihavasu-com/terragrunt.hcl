# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# https://github.com/gruntwork-io/terragrunt/
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # https://github.com/ihavasu/infra-modules/tree/main/gcp/networking/cloud-dns-public"
  source = "git::git@github.com:ihavasu/infra-modules/gcp/networking/cloud-dns-public"
}

include {
  path = find_in_parent_folders()
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  domain = "cc-dev-gcp.ihavasu.com."
  name = "cc-dev-gcp-ihavasu-com"
  decription = "Terraform managed public zone for chatbot-challenge dev project"

  recordsets = [
    {
      name    = "local"
      type    = "A"
      ttl     = 300
      records = [
        "127.0.0.1",
      ]
    },
  ]

  labels = {
    Environment = "dev"
  }
}
