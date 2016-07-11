# encoding: utf-8
require 'spec_helper'
require "logstash/filters/graph"
require 'json'

describe LogStash::Filters::Graph do
  describe "Set to Hello World" do
    let(:filter) { LogStash::Plugin.lookup("filter", "graph").new({"configfile" => File.join(File.dirname(__FILE__), "user.json"), "key" => "beat.hostname"}) }
    let(:event) do
      LogStash::Event.new({
        "message" => "some message",
        "beat" => {
            "hostname" => "scaleworks.analytics.es.2.scaleworks.com",
            "name" => "scaleworks.analytics.es.2.scaleworks.com"
        },
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
