locals {
  servers = toset([
    "server",
    "node-0",
    "node-1"
  ])
}

resource "hcloud_network" "this" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "this" {
  type         = "cloud"
  network_id   = hcloud_network.this.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_server" "this" {
  for_each = local.servers

  name        = each.key
  image       = "debian-12"
  server_type = "cax11"
  location    = "nbg1"
  user_data   = file("assets/user-data")
  ssh_keys    = [for key in hcloud_ssh_key.main : key.id]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  network {
    network_id = hcloud_network.this.id
    alias_ips  = []
  }

  depends_on = [
    hcloud_network_subnet.this
  ]
}
