# encoding: utf-8
require 'spec_helper'
require "logstash/filters/neo4j"
require 'json'

describe LogStash::Filters::Neo4j do
  describe "Set to Hello World" do
    let(:filter) { LogStash::Plugin.lookup("filter", "neo4j").new({"computerid" => "10.202.4.210"}) }
    let(:event) do
      LogStash::Event.new({
        "message" => "some message",
        "seq" => rand(1000),
        "@version" => "1",
        "@timestamp" => Time.now.utc.iso8601(3)
      })
    end

    before do
      filter.register
      filter.filter(event)
    end

    it "should have a location field" do
      puts "***", event["dependency_of"], "*", event["depends_on"], "*", event["about"], "***"

    end
  end
end
