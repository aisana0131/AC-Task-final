variable "okta_users" {
  type = map(object({
    first_name = string
    last_name  = string
    email      = string
    groups     = list(string)
  }))
}