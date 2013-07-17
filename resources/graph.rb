actions :add, :delete

default_action :create

def initialize(*args)
  super
  @action = :create
end

# The name of the graph
attribute :name, :kind_of => String, :name_attribute => true

# The URL/Port of the descartes server (autoselected if nil)
attribute :descartes_hostname, :kind_of => [String,NilClass], :default => nil
attribute :descartes_port, :kind_of => [Integer,NilClass], :default => nil

# An array of graphite target functions
attribute :targets, :kind_of => Array

# An optional dashboard to attach the graph to
attribute :dashboard, :kind_of => [String,NilClass], :default => nil

# An optional array of tag to apply to the graph
attribute :tags, :kind_of => Array, :default => []

# Use the common name format?
attribute :common_format, :kind_of => [TrueClass,FalseClass], :default => false

private

attribute :graph_data
