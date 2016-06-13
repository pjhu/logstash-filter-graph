# encoding: utf-8
require 'spec_helper'
require "logstash/filters/neo4j"
require 'json'

describe LogStash::Filters::Neo4j do
  describe "Set to Hello World" do
    let(:filter) { LogStash::Plugin.lookup("filter", "neo4j").new({"host" => "192.168.45.56:7474", "user" => "neo4j", "password" => 123456, "index" => "idx_vm", "key" => "id", "value" => "vm-21"}) }
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
      puts "***", event["monitored_entity_id"], event["depency_of"], event["depend_on"], "***"

    end
  end
end
