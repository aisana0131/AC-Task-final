module "final_ec2" {
  source = "./modules/ec2"

  ami_id      = var.ami_id
  instance_type = var.instance_type
  name        = var.name
  environment = var.environment
}

provider "okta" {
  org_name       = var.okta_org_name
  base_url       = var.okta_base_url
  client_id      = var.okta_client_id
  scopes         = var.okta_scopes
  private_key_id = var.okta_private_key_id
  private_key    = data.aws_secretsmanager_secret_version.okta_private_key.secret_string
}

data "aws_secretsmanager_secret_version" "okta_private_key" {
  secret_id = ""
}


module "okta_users" {
  source = "./modules/okta-users"

  users          = var.okta_users
  default_groups = var.default_groups
}
