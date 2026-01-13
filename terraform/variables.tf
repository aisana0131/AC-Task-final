variable "region" {
  type        = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "okta_org_name" {
  type        = string
}

variable "okta_base_url" {
  type        = string
}

variable "okta_client_id" {
  type        = string
}

variable "okta_scopes" {
  type        = list(string)
}

variable "okta_private_key_id" {
  type        = string
}

variable "okta_users" {
  type = map(object({
    first_name = string
    last_name  = string
    email      = string
    groups     = list(string)
  }))
}

variable "default_groups" {
  type        = list(string)
  default     = []
}