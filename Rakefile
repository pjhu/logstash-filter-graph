require "logstash/devutils/rake"

BUILD_VERSION_FILE_PATH = 'build/version'

namespace :build  do

  GEMSPEC = 'logstash-filter-graph.gemspec'
  BUILD_NUM_ENV_VAR = 'BUILD_NUM'
  @logstash_version = '2.3'

  desc "task for building the gem"
  task :build_gem do
    sh "gem build #{GEMSPEC}"
  end

  desc "task for dumping the build version to file:build/version"
  task :dump_version do
    require "rubygems"

    spec = Gem::Specification::load(GEMSPEC)

    build_num = ENV[BUILD_NUM_ENV_VAR]? ENV[BUILD_NUM_ENV_VAR]: "dev"

    build_version = "#{@logstash_version}-#{spec.version}-#{build_num}"

    File.delete(BUILD_VERSION_FILE_PATH) if File.exist?(BUILD_VERSION_FILE_PATH)#delete version file to make sure there is only one line in it
    File.open(BUILD_VERSION_FILE_PATH, 'w') { |file| file.write(build_version) }
  end

  desc "task for rendering Dockrfile"
  task :dockerfile do
    require 'erb'


    template = ERB.new File.read("Dockerfile.erb")
    dockrfile = template.result(binding)

    File.delete('Dockerfile') if File.exist?('Dockerfile')#delete version file to make sure there is only one line in it
    File.open('Dockerfile', "w+") do |f|
      f.write(dockrfile)
    end
  end
end
