#Chef::Resource::User.send(:include,::Extensions)
[Chef::Recipe, Chef::Resource].each { |l| l.send :include, ::Extensions }

directory "#{node['es']['path.home']}/plugins/" do
  owner "#{node['es']['user']}"
  group "#{node['es']['group']}"
  mode 0755
  recursive true
end

node[:elasticsearch][:plugins].each do | name, config |
  next if name == 'elasticsearch/elasticsearch-cloud-aws' && !node.recipe?('aws')
  next if name == 'elasticsearch/elasticsearch-cloud-gce' && !node.recipe?('gce')
  install_plugin name, config
end
