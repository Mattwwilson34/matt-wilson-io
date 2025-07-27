# SSH public keys for server access
ssh_public_key_path = "~/.ssh/digital_ocean_mattwilson_io_work.pub"


# Your domain name  
domain_name = "mattwilson.io"

# Server configuration - $4/month option
droplet_size = "s-1vcpu-512mb-10gb" # $4/month 
region       = "nyc1"               # New York datacenter
project_name = "matt-wilson-io"

# Note: DO_TOKEN is read from environment variable TF_VAR_do_token
