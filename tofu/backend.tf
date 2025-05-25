variable "state_password" {
  type = string
}

terraform {
  encryption {

    key_provider "pbkdf2" "password" {
      passphrase = var.state_password
    }

    method "aes_gcm" "password" {
      keys = key_provider.pbkdf2.password
    }

    state {
      method   = method.aes_gcm.password
      enforced = true
    }
  }
}
