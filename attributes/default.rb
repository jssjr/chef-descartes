default['descartes']['host_name'] = 'descartes'
default['descartes']['host_aliases'] = [ 'descartes' ]
default['descartes']['proxy_port'] = 80

default['descartes']['session_secret'] = 'change_me'
default['descartes']['graphite_url'] = 'http://localhost'
default['descartes']['oauth_provider'] = 'google'
default['descartes']['google_oauth_domain'] = 'example.com'
default['descartes']['metrics_update_interval'] = '15m'
default['descartes']['graphite_user'] = ''
default['descartes']['graphite_pass'] = ''
default['descartes']['api_key'] = nil # nil or empty means NO api key will be set

default['descartes']['role_name'] = 'dashboard_server'
