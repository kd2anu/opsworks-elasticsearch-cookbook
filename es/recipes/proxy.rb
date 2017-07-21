include_recipe "es::nginx" unless node.recipe?('nginx')

# Create proxy with HTTP authentication via Nginx
#
template "#{node[:nginx][:dir]}/conf.d/elasticsearch_proxy.conf" do
  source "elasticsearch_proxy.conf.erb"
  owner node[:nginx][:user] and group node[:nginx][:user] and mode 0755
  notifies :reload, 'service[nginx]'
end

ruby_block "add #{node[:nginx][:users]} to passwords file" do
  block do
    require 'webrick/httpauth/htpasswd'
    @htpasswd = WEBrick::HTTPAuth::Htpasswd.new(node[:nginx][:passwords_file])

    node[:nginx][:users].each do |u|
      Chef::Log.debug "Adding user '#{u['username']}' to #{node.elasticsearch[:nginx][:passwords_file]}\n"
      @htpasswd.set_passwd( 'Elasticsearch', u['username'], u['password'] )
    end

    @htpasswd.flush
  end

  not_if { node[:nginx][:users].empty? }
end

# Ensure proper permissions and existence of the passwords file
#
file node[:nginx][:passwords_file] do
  owner node[:nginx][:user] and group node[:nginx][:user] and mode 0755
  action :touch
end
