# Descartes Cookbook

[Descartes](https://github.com/obfuscurity/descartes) is a collaborative dashboard and graph management tool for [Graphite](https://github.com/graphite-project). This cookbook installs and manages a Descartes instance and offers a number of LWRP's you can use to manage graphs in the graph system. Mix together some collectd with write_graphite, maybe a side of statsd or riemann, and even some artisinal data collection scripts, then toss in this Descartes cookbook and you're ready to serve up some serious monitoring love.

# Requirements

### Cookbooks

- [apache2](https://github.com/opscode-cookbooks/apache2)
- [application_ruby](https://github.com/opscode-cookbooks/application_ruby)
- [database](https://github.com/opscode-cookbooks/database)
- [postgresql](https://github.com/opscode-cookbooks/postgresql)
- [redis](https://github.com/miah/chef-redis)
- [runit](https://github.com/opscode-cookbooks/runit)

### Other ingredients

- A working Graphite server.
- An oauth source from GitHub or Google.

# Attributes

#### API service configuration

- `default['descartes']['host_name']`
  - Set the hostname for the Descartes service. Default: `'descartes'`

- `default['descartes']['host_aliases']`
  - You can add any hostname aliases you need here. Default: `[ 'descartes' ]`

- `default['descartes']['proxy_port']`
  - Set the proxy port here. Default: `80`

- `default['descartes']['session_secret']`
  - Set a session secret. You should override this. Default: `'change_me'`

- `default['descartes']['graphite_url']`
  - The location of the graphite server. Default: `'http://graphite'`

- `default['descartes']['graphite_user']`
  - Basic HTTP auth username for Graphite (if needed) Default: `''`

- `default['descartes']['graphite_pass']`
  - Basic HTTP auth password for Graphite (if needed) Default: `''`

- `default['descartes']['api_key']`
  - An API key for the LWRP's to use. Default: `'can_haz_graphs'`

- `default['descartes']['metrics_update_interval']`
  - How often to pull metrics from the graphite server into the Descartes cache. Default: `'15m'`


#### Dashboard

- `default['descartes']['oauth_provider']`
  - The Oauth provider to use. Options: `google` or `github` Default: `github`

- `default['descartes']['google_oauth_domain']`
  - The Oauth domain for Google Apps. Default: `'google.com'`

#### LWRP search configuration

- `default['descartes']['role_name']`
  - The dashboard server role is one way to inform LWRP's where the Descartes API lives. Default: `'dashboard_server'`


# Usage
-----

#### descartes::default

Simply include `descartes` in your node's `run_list` and set the values you want to override.

If you use a wrapper cookbook for your dashboard services, you may have a descartes recipe like the following:

```ruby
node.set['descartes']['session_secret'] = 'supersecretstuffnohints'
node.set['descartes']['graphite_url']   = 'http://graphite.company.com'
node.set['descartes']['oauth_provider'] = 'google'
node.set['descartes']['api_key'] = 'mycompanysecret'
node.set['descartes']['google_oauth_domain'] = 'company.com'

node.set['descartes']['host_name'] = 'descartes.company.com'

include_recipe 'descartes'
include_recipe 'descartes::proxy_apache2'
```

#### descartes::proxy_apache2

Set's up an Apache httpd proxy for descartes.

# Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using GitHub

# Authors

Authors: Scott Sanders <scott@jssjr.com>

# License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
