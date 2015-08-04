Chef::Log.info("******Creating layer-custom directory.******")

data_dir = value_for_platform(
  "centos" => { "default" => "/etc/layer-custom" },
  "ubuntu" => { "default" => "/etc/layer-custom" },
  "default" => "/etc/layer-custom"
)

directory data_dir do
  mode 0755
  owner 'root'
  group 'root'
  recursive true
  action :create
end
