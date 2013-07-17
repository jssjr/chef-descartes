include_recipe 'apache2'
include_recipe 'apache2::mod_rewrite'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'

apache_module 'vhost_alias'

template "#{node['apache']['dir']}/sites-available/descartes" do
  source      'descartes-vhost.conf.erb'
  owner       'root'
  mode        '0644'
  variables(
    :host_name    => node['descartes']['host_name'],
    :host_aliases => node['descartes']['host_aliases'],
    :port         => node['descartes']['proxy_port'],
  )

  if File.exists?("#{node[:apache][:dir]}/sites-enabled/descartes")
    notifies  :restart, 'service[apache2]'
  end
end

apache_site '000-default' do
  enable  false
end

apache_site 'descartes' do
  enable true
end
