locals {
  servers = toset([
    "server",
    "node-0",
    "node-1",
    "jumphost"
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

resource "hcloud_firewall" "k8s_nodes" {
  name = "private_network"

  rule {
    direction  = "in"
    port       = "any"
    protocol   = "tcp"
    source_ips = [hcloud_network.this.ip_range]
  }

  rule {
    direction  = "in"
    port       = "any"
    protocol   = "udp"
    source_ips = [hcloud_network.this.ip_range]
  }

  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = [hcloud_network.this.ip_range]
  }

  rule {
    direction       = "out"
    port            = "any"
    protocol        = "tcp"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    port            = "any"
    protocol        = "udp"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    protocol        = "icmp"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_firewall_attachment" "this" {
  firewall_id = hcloud_firewall.k8s_nodes.id
  server_ids  = [for server_name, server_config in hcloud_server.this : server_config.id if server_name != "jumphost"]
}

resource "hcloud_firewall" "jumphost" {
  name = "jumphost"

  rule {
    direction = "in"
    port      = "22"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction       = "out"
    port            = "any"
    protocol        = "tcp"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    port            = "any"
    protocol        = "udp"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    protocol        = "icmp"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_firewall_attachment" "jumphost" {
  firewall_id = hcloud_firewall.jumphost.id
  server_ids  = [hcloud_server.this["jumphost"].id]
}
