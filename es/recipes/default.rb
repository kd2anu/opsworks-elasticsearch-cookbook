group "#{node['es']['group']}" do
  action :create
  system true
  not_if "grep -q ^#{node['es']['group']} /etc/group"
end

user "#{node['es']['user']}" do
  gid "#{node['es']['group']}"
  shell   "/bin/bash"
  action  :create
  system true
  not_if "grep -q ^#{node['es']['user']} /etc/passwd"
end

# set user/group on data directory:
directory "#{node['es']['path.data']}" do
  owner "#{node['es']['user']}"
  group "#{node['es']['group']}"
  mode '0755'
  action :create
end

# download RPM from URL:
remote_file "/root/#{node['es']['pkg.name']}" do
  source "#{node['es']['source']}"
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  checksum "#{node['es']['pkg.sha256']}"
  not_if "[ -f /root/#{node['es']['pkg.name']} ]"
end

# install RPM:
rpm_package "/root/#{node['es']['pkg.name']}" do
  action :install
  not_if "rpm -qa |grep -q #{node['es']['pkg.name'].chomp('.rpm')}"
end

# cloud-aws plugin:
execute 'install cloud-aws plugin' do
  command "/usr/share/elasticsearch/bin/plugin install elasticsearch/elasticsearch-cloud-aws/#{node['es']['cloud-aws.version']}"
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
