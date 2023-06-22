# NOTE:
# This code doesn't work. All resources fail to apply with the following error:
# `Authentication error (10000)`. Both `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_API_KEY`
# have been tested.


terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.6"
    }
  }
}

provider "random" {}

provider "cloudflare" {}

# For testing
variable "tunnel_id" {
  type    = string
  default = "cefcc7a1-55cc-4673-8ca5-81fa66dbea30"
}

data "cloudflare_accounts" "my" {
  name = "Daniel.kneipp@outlook.com's Account"
}

resource "random_id" "tunnel_secret" {
  byte_length = 32
}

resource "cloudflare_tunnel" "my" {
  account_id = data.cloudflare_accounts.my.id
  name       = "my-tunnel"
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_tunnel_route" "ipv4" {
  account_id = data.cloudflare_accounts.my.id
  tunnel_id  = cloudflare_tunnel.my.id
  network    = "0.0.0.0/0"
  comment    = "New tunnel route for documentation"
}

resource "cloudflare_tunnel_route" "ipv6" {
  account_id = data.cloudflare_accounts.my.id
  tunnel_id  = cloudflare_tunnel.my.id
  network    = "::/0"
  comment    = "New tunnel route for documentation"
}
