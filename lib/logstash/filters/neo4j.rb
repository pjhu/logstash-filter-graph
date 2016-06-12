# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

# This neo4j filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an neo4j.
class LogStash::Filters::Neo4j < LogStash::Filters::Base

  config_name "neo4j"

  # List of neo4j host to use for querying.
  config :host, :validate => :string

  # Neo4j query string
  config :query, :validate => :string

  # Basic Auth - username
  config :user, :validate => :string

  # Basic Auth - password
  config :password, :validate => :password

  public
  def register
    # Add instance variables
    require "neography"
    if @user && @password && @host
      @neo_url = "http://#{@user}:#{@password.value}@#{@host}"
      @neo = Neography::Rest.new(@neo_url)
    end
  end # def register

  public
  def filter(event)
    if @query
      event["neo4j"] = @neo.get_nodes_labeled(@query)
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Neo4j
