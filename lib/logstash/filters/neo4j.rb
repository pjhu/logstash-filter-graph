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
  config :index, :validate => :string

  # Neo4j node key string
  config :key, :validate => :string

  # Neo4j node value string
  config :value, :validate => :string

  # Basic Auth - username
  config :user, :validate => :string

  # Basic Auth - password
  config :password, :validate => :password

  public
  def register
    # Add instance variables
    require "neography"
    begin
      if @user && @password && @host
        @neo_url = "http://#{@user}:#{@password.value}@#{@host}"
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
      if @index && @key && @value
        idx = @neo.get_node_index(@index, @key, @value)
        event["neo4j"] = @neo.get_node_relationships(idx[0]["metadata"]["id"]) if idx.size > 0
      end
    rescue Neography::NotFoundException => e
      @logger.warn("Failed to find node: #{@index},#{@key},#{@value}")
    rescue Exception => e
      raise e
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Neo4j
