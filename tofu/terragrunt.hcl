terraform {
  extra_arguments "set environment variable for cache directory" {
    commands = ["init"]
    env_vars = {
      TF_PLUGIN_CACHE_DIR = get_env("TF_PLUGIN_CACHE_DIR", "${get_env("HOME")}/.cache/terraform/plugin-cache")
    }
  }

  before_hook "create plugin cache directory if absent" {
    commands = ["init"]
    execute  = ["bash", "-c", "test -d \"$TF_PLUGIN_CACHE_DIR\" || mkdir -p \"$TF_PLUGIN_CACHE_DIR\""]
  }
}

terraform_binary = "tofu"