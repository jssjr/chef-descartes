#
# Cookbook Name:: descartes
# Recipe:: default
#
# Copyright 2013, RideCharge, Inc.
#
# All rights reserved - Do Not Redistribute
#

ruby_version = '1.9.3-p194'

include_recipe 'redis'
include_recipe 'postgresql::server'
include_recipe 'database::postgresql'
include_recipe 'runit'

postgresql_connection_info = { :host     => 'localhost',
                               :port     => node['postgresql']['config']['port'],
                               :username => node['postgresql']['user'],
                               :password => node['postgresql']['password']['postgres'] }

postgresql_database 'descartes' do
  connection postgresql_connection_info
  action :create
end

descartes_env = {
  "PATH" => "/opt/rubies/#{ruby_version}/bin:#{ENV['PATH']}",
  "DATABASE_URL" => "postgres://#{node['postgresql']['user']}:#{node['postgresql']['password']['postgres']}@localhost/descartes",
  "RACK_ENV" => 'production',
  "SESSION_SECRET" => node['descartes']['session_secret'],
  "GRAPHITE_URL" => node['descartes']['graphite_url'],
  "OAUTH_PROVIDER" => node['descartes']['oauth_provider'],
  "GOOGLE_OAUTH_DOMAIN" => node['descartes']['google_oauth_domain'],
  "METRICS_UPDATE_INTERVAL" => node['descartes']['metrics_update_interval']
}
descartes_env['GRAPHITE_USER'] = node['descartes']['graphite_user'] if node['descartes']['graphite_user']
descartes_env['GRAPHITE_PASS'] = node['descartes']['graphite_pass'] if node['descartes']['graphite_pass']
descartes_env['API_KEY'] = node['descartes']['api_key'] if node['descartes']['api_key']

application 'descartes' do

  action :deploy

  path '/opt/descartes'
  owner 'descartes'
  group 'descartes'
  repository 'git://github.com/obfuscurity/descartes.git'
  revision 'master'
  migrate true
  environment_name 'production'
  environment descartes_env

  user do
    user 'descartes'
    uid 954
    group 'descartes'
    gid 954
    path "/opt/rubies/#{ruby_version}/bin:#{ENV['PATH']}"
    ssh_keys_path '/usr/local/etc/ssh/keys/descartes'
  end

  ruby do
    version ruby_version
  end

  sinatra do
    gems ['rake', 'unicorn']
    bundler true
    bundle_command "/opt/rubies/#{ruby_version}/bin/bundle"
  end

  thin do
    port "8080"
    env descartes_env
    bundler true
    bundle_command "/opt/rubies/#{ruby_version}/bin/bundle"
  end

end
