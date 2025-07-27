terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0"
}

provider "digitalocean" {
  token = var.do_token
}

# SSH Keys for server access
resource "digitalocean_ssh_key" "mattwilson_key" {
  name       = "${var.project_name}-key"
  public_key = file(var.ssh_public_key_path)
}

# Main server droplet  
resource "digitalocean_droplet" "mattwilson_server" {
  image  = "ubuntu-22-04-x64"
  name   = "${var.project_name}-server"
  region = var.region
  size   = var.droplet_size

  ssh_keys = [digitalocean_ssh_key.mattwilson_key.id]

  user_data = templatefile("${path.module}/cloud-init.yml", {
    ssh_public_key = file(var.ssh_public_key_path)
    domain_name    = var.domain_name
  })
}

# Firewall for security
resource "digitalocean_firewall" "mattwilson_firewall" {
  name = "${var.project_name}-firewall"

  droplet_ids = [digitalocean_droplet.mattwilson_server.id]

  # SSH access only from your IP
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["136.47.170.156/32"] # Only my IP
  }

  # HTTP (port 80)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS (port 443)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # All outbound traffic allowed
  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Domain management  
resource "digitalocean_domain" "mattwilson_domain" {
  name = var.domain_name
}

# Main domain record (mattwilson.io -> server IP)
resource "digitalocean_record" "mattwilson_a_record" {
  domain = digitalocean_domain.mattwilson_domain.name
  type   = "A"
  name   = "@"
  value  = digitalocean_droplet.mattwilson_server.ipv4_address
  ttl    = 300
}

# WWW subdomain (www.mattwilson.io -> mattwilson.io)
resource "digitalocean_record" "mattwilson_www_record" {
  domain = digitalocean_domain.mattwilson_domain.name
  type   = "CNAME"
  name   = "www"
  value  = "@"
  ttl    = 300
}
