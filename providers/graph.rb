# Example : https://github.com/obfuscurity/descartes/wiki/API
#
# $ curl -H 'Accept: application/json' -H 'X-DESCARTES-API-TOKEN: foobar' -d 'name=My New Graph' -d 'tag=foo' \
#   --data-urlencode 'node=https://graphite.example.com/render/?target=carbon.agents.li520-115-a.metricsReceived' \
#   -X POST http://127.0.0.1:5000/graphs
#
# {
#   "json_class": "Graph",
#   "id": 15,
#   "uuid": "004f0ffa5334f74f863385ed230a6fb0",
#   "owner": "api@localhost",
#   "name": "Please name me",
#   "description": null,
#   "url": "https://graphite.example.com/render/?target=carbon.agents.li520-115-a.metricsReceived",
#   "configuration": "{'target':['carbon.agents.li520-115-a.metricsReceived']}",
#   "overrides": null,
#   "enabled": true,
#   "created_at": "2013-03-13 16:36:10 -0400",
#   "updated_at": "2013-03-13 16:36:10 -0400",
#   "views": 0
# }

def load_current_resource
  require 'cgi'

  @current_resource = Chef::Resource::DescartesGraph.new(@new_resource.name)

  descartes_hostname, descartes_port = locate_descartes_server
  Chef::Log.debug("#{@new_resource} Connecting to (#{descartes_hostname}, #{descartes_port})")
  Chef::Log.debug("#{@new_resource} Using headers #{headers}")
  @client ||= Net::HTTP.new(descartes_hostname, descartes_port)

  # Look up the current graph data from descartes

  search_term = URI::encode(graph_name)
  Chef::Log.debug("#{@new_resource} Searching for #{search_term}")
  body = @client.get("/graphs?search=#{search_term}", headers)
  JSON.create_id = nil
  matches = JSON.parse(body.read_body)

  if matches.empty?
    # The graph doesn't exist
    Chef::Log.debug("#{@new_resource} No Descartes graph found before create")
  elsif matches.size > 1
    # More than one graph matches
    matches.each do |m|
      Chef::Log.debug("#{@new_resource} Purging Descartes graph before create: #{m}")
      # Delete them
      @client.delete("/graphs/#{m['uuid']}", headers)
    end
  else
    # Match found
    m = matches.first
    m['configuration'] = JSON.parse(m['configuration'])
    Chef::Log.debug("#{@new_resource} Located Descartes graph: #{m}")
    if targets_equal?(m['configuration']['target'], @new_resource.targets)
      @new_resource.graph_data(m)
    end
  end

  @current_resource
end

action :create do
  converge_by("#{@new_resource} create graph") do
    @new_resource.updated_by_last_action(true)

    if @new_resource.graph_data.nil?
      Chef::Log.info("#{@new_resource} Creating!")
      # $ curl -H 'Accept: application/json' -H 'X-DESCARTES-API-TOKEN: foobar' -d 'name=My New Graph' -d 'tag=foo' \
      #   --data-urlencode 'node=https://graphite.example.com/render/?target=carbon.agents.li520-115-a.metricsReceived' \
      #   -X POST http://127.0.0.1:5000/graphs

      graph_url = "http://#{node['graphite']['url']}/render/?"
      graph_targets = Array.new
      @new_resource.targets.each do |target|
        graph_targets << "target=#{target}"
      end
      graph_url << graph_targets.join('&')

      data = Array.new
      data << "node=#{CGI::escape(URI::encode(graph_url))}"
      data << "name=#{CGI::escape(graph_name)}"
      data << "tag[]=chef_managed"
      data << "tag[]=#{CGI::escape(node.chef_environment)}"
      @new_resource.tags.each {|t| data << "tag[]=#{CGI::escape(t)}"}

      Chef::Log.debug("#{@new_resource} Posting new graph with #{data.join('&')}")
      body, result = @client.post("/graphs", data.join('&'), headers)
      Chef::Log.debug("#{@new_resource} Post result is #{result}")
    end

  end
end

action :delete do
  converge_by("#{@new_resource} delete graph") do
    @new_resource.updated_by_last_action(true)

    if @new_resource.graph_data
      Chef::Log.info("#{@new_resource} Deleting!")
    end

  end
end

private

def descartes_get(url)
  body = @client.get(
    url,
    false,
    auth_header
  )
  body
end

def descartes_post(url, data)
  body = @client.post(
    url,
    data,
    auth_header
  )
  body
end

def descartes_delete(url)
  body = @client.delete(
    url,
    auth_header
  )
  body
end

def headers
  {
    "X-DESCARTES-API-TOKEN" => locate_api_token,
    "Accept" => "application/json",
  }
end

# Check if the arrays of targets are equal using XOR
def targets_equal?(a, b)
  Chef::Log.debug("Comparing: #{a} to #{b}")
  ( (a | b) - (a & b) ).length == 0
end

def graph_name
  if @new_resource.common_format
    "#{node.chef_environment} - #{node['fqdn']} - #{@new_resource.name}"
  else
    @new_resource.name
  end
end

def locate_api_token
  unless Chef::Config[:solo]
    @descartes_node ||= search(:node, "roles:#{node['descartes']['role_name']}").first
    unless @descartes_node.nil?
      @descartes_token ||= @descartes_node['descartes']['api_key']
    end
  end

  @descartes_token ||= node['descartes']['api_key']
end

def locate_descartes_server
  unless Chef::Config[:solo]
    @descartes_node ||= search(:node, "roles:#{node['descartes']['role_name']}").first
    unless @descartes_node.nil?
      descartes_hostname = @new_resource.descartes_hostname || @descartes_node['descartes']['host_name']
      descartes_port = @new_resource.descartes_port || @descartes_node['descartes']['proxy_port']
    end
  end

  descartes_hostname ||= @new_resource.descartes_hostname || node['descartes']['host_name']
  descartes_port ||= @new_resource.descartes_port || node['descartes']['proxy_port']

  [descartes_hostname, descartes_port]
end
