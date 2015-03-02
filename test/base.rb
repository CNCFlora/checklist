ENV['RACK_ENV'] = 'test'

require_relative '../src/app'

require 'rspec'
require 'rack/test'
require 'rspec-html-matchers'
require 'cncflora_commons'
require 'uri'

include Rack::Test::Methods

def app
    Sinatra::Application
end

RSpec.configure do |config|
  config.include RSpecHtmlMatchers
end

setup 'config.yml'

http_get("#{settings.couchdb}/cncflora_test/_all_docs")["rows"].each {|r|
  http_delete("#{settings.couchdb}/cncflora_test/#{r["id"]}?rev=#{r["value"]["rev"]}");
}
http_delete("#{settings.couchdb}/vacro_123")

