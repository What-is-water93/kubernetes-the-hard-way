output "ip" {
  value = {
    for server_name, server_config in hcloud_server.this :
    server_name => {
      public_ip  = server_config.ipv4_address
      private_ip = one(server_config.network[*].ip)

    }
  }
}
