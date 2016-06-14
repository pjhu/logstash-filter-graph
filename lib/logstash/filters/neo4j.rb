# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require 'json'

# This neo4j filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an neo4j.
class LogStash::Filters::Neo4j < LogStash::Filters::Base

  config_name "neo4j"

  # List of neo4j host to use for querying.
  config :host, :validate => :string

  # Neo4j node index string
  config :index, :validate => :string, :default => 'idx_obj_id'

  # Neo4j node key string
  config :key, :validate => :string, :default => 'obj_id'

  # Neo4j node value string
  config :computerid, :validate => :string

  # Basic Auth - username
  config :user, :validate => :string

  # Basic Auth - password
  config :password, :validate => :password

  public
  def register
    # Add instance variables
    require "neography"
    begin
      config = JSON.parse(File.read(File.join(File.dirname(__FILE__), "user.json")))
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
      if @index && @key && @computerid
        nodes = @neo.get_node_index(@index, @key, @computerid)
        if nodes && nodes.size > 0
          node = nodes[0]
          event["obj_id"] = node["data"]["obj_id"]
          relations = @neo.get_node_relationships(node)
          event["dependency_of"] = relations.select {|rel| rel["data"]["end"] == node["data"]["obj_id"]}.map {|rel| rel["data"]["start"]}
          event["depends_on"] = relations.select {|rel| rel["data"]["start"] == node["data"]["obj_id"]}.map {|rel| rel["data"]["end"]}
          event["about"] = [event["obj_id"], event["dependency_of"]]
        end
      end
    rescue Neography::NotFoundException => e
      @logger.warn("Failed to find node: #{@index},#{@key},#{@computerid}")
    rescue Exception => e
      raise e
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Neo4j
