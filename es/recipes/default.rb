group node['es']['group'] do
  action :create
  system true
end

user node['es'][:user] do
  shell   "/bin/bash"
  action  :create
  system true
end

bash "remove ES user home" do
  user    'root'
  code    "rm -rf  #{node.elasticsearch[:dir]}/elasticsearch"
  only_if { ::File.directory?("/home/elasticsearch") }
end

# set user/group on data directory:
directory "#{node['es']['path.data']}" do
  owner 'elasticsearch'
  group 'elasticsearch'
  mode '0755'
  action :create
end

# download RPM from URL:
remote_file "/var/chef/cache/#{node['es']['pkg.name']}" do
  source "https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/#{node['es']['version']}/#{node['es']['pkg.name']}"
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  checksum "#{node['es']['pkg.sha256']}"
  not_if "[ -f /var/chef/cache/#{node['es']['pkg.name']} ]"
end

# install RPM:
rpm_package "/var/chef/cache/#{node['es']['pkg.name']}" do
  action :install
  not_if "rpm -qa |grep -q #{node['es']['pkg.name'].chomp('.rpm')}"
end

# cloud-aws plugin:
execute 'install cloud-aws plugin' do
  command '/usr/share/elasticsearch/bin/plugin install cloud-aws -b'
  not_if '[ -d /usr/share/elasticsearch/plugins/cloud-aws ]'
end

# ES sysconfig:
template '/etc/sysconfig/elasticsearch' do
  source 'elasticsearch.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, 'service[elasticsearch]'
end

# ES config:
template '/etc/elasticsearch/elasticsearch.yml' do
  source 'elasticsearch.yml.erb'
  mode '0750'
  owner 'elasticsearch'
  group 'elasticsearch'
  notifies :restart, 'service[elasticsearch]'
end

# ES service definition:
service 'elasticsearch' do
  supports :status => true, :restart => true, :reload => true
  subscribes :restart, ['template[/etc/sysconfig/elasticsearch]','template[/etc/elasticsearch/elasticsearch.yml]']
end 

