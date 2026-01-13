resource "okta_user" "users" {
  for_each = var.okta_users

  first_name = each.value.first_name
  last_name  = each.value.last_name
  login      = each.value.email
  email      = each.value.email
}

resource "okta_user_group_memberships" "memberships" {
  for_each = var.okta_users

  user_id = okta_user.users[each.key].id
  groups  = each.value.groups
}