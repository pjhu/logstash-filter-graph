# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require 'json'

# This neo4j filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an neo4j.
class LogStash::Filters::Graph < LogStash::Filters::Base

  config_name "graph"

  # List of neo4j host to use for querying.
  config :host, :validate => :string

  # Neo4j node index string
  config :index, :validate => :string, :default => 'idx_obj_id'

  # Neo4j node key string
  config :value, :validate => :string, :default => 'obj_id'

  # Neo4j node value string
  config :key, :validate => :string

  # Basic Auth - username
  config :user, :validate => :string

  # Basic Auth - password
  config :password, :validate => :password

  # Basic Auth File
  config :configfile, :validate => :string

  public
  def register
    # Add instance variables
    require "neography"
    begin
      config = JSON.parse(File.read(@configfile))
      @host = config["host"]
      @user = config["username"]
      @password = config["password"]
      if @host && @user && @password
        @neo_url = "http://#{@user}:#{@password}@#{@host}"
        @neo = Neography::Rest.new(@neo_url)
      else
        @logger.warn("You must specify user, password, and host")
      end
    rescue Excon::Errors::SocketError => e
      @logger.error("Connection refused", :exception => e, :field => @source)
    rescue Exception => e
      raise e
    end
  end # def register

  public
  def filter(event)
    begin
      if @key.blank?
        keys = ""
      else
        keys = event
        @key.split('.').each{|k| keys=keys[k]}
      end
      if @index && @value && !keys.blank?
        nodes = @neo.get_node_index(@index, @value, keys)
        if nodes && nodes.size > 0
          node = nodes[0]
          event["obj_id"] = node["data"]["obj_id"]
          relations = @neo.get_node_relationships(node)
          event["dependency_of"] = relations.select {|rel| rel["data"]["end"] == node["data"]["obj_id"]}.map {|rel| rel["data"]["start"]}
          event["depends_on"] = relations.select {|rel| rel["data"]["start"] == node["data"]["obj_id"]}.map {|rel| rel["data"]["end"]}
          event["about"] = [event["obj_id"]]
          event["about"].concat(event["dependency_of"])
        end
      end
    rescue Neography::NotFoundException => e
      @logger.warn("Failed to find node: #{@index},#{@value},#{event[@key]}")
    rescue Exception => e
      raise e
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Neo4j
