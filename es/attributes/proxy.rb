include_attribute "es::default"
include_attribute "es::nginx"

# === NGINX ===
# Allowed users are set based on data bag values, when it exists.
#
# It's possible to define the credentials directly in your node configuration, if your wish.
#
default[:nginx][:server_name]    = "elasticsearch"
default[:nginx][:port]           = "8080"
default[:nginx][:username] = "#{node['elasticsearch']['nginx']['users']['username']}"
default[:nginx][:password] = "#{node['elasticsearch']['nginx']['users']['password']}"
default[:nginx][:passwords_file] = "#{default['es']['path.conf']}/passwords"

# Deny or allow authenticated access to cluster API.
#
# Set this to `true` if you want to use a tool like BigDesk
#
default[:nginx][:allow_cluster_api] = false

# Allow responding to unauthorized requests for `/status`,
# returning `curl -I localhost:9200`
#
default[:nginx][:allow_status] = false

# Other Nginx proxy settings
#
default[:nginx][:client_max_body_size] = "50M"
default[:nginx][:location] = "/"
default[:nginx][:ssl][:cert_file] = nil
default[:nginx][:ssl][:key_file] = nil
