locals {
  keys = yamldecode(file("keys.yaml"))
}

resource "hcloud_ssh_key" "main" {
  for_each = local.keys

  name       = each.key
  public_key = each.value
}
