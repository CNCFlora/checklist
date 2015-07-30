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

def before_each()
    # Wait until ES docker is up
    sleep 5;

    uri = "#{Sinatra::Application.settings.couchdb}/cncflora"
    uri2 = "#{ Sinatra::Application.settings.elasticsearch }/cncflora"
    http_delete(uri)
    http_delete(uri2)
    http_put(uri, {})
    http_put(uri2, {})

    uri = "#{Sinatra::Application.settings.couchdb}/cncflora_test"
    uri2 = "#{ Sinatra::Application.settings.elasticsearch }/cncflora_test"
    http_delete(uri)
    http_delete(uri2)
    http_put(uri, {})
    http_put(uri2, {})

    http_delete("#{Sinatra::Application.settings.couchdb}/vacro_123")
end

def after_each()
    uri = "#{Sinatra::Application.settings.couchdb}/cncflora"
    uri2 = "#{ Sinatra::Application.settings.elasticsearch }/cncflora"
    http_delete(uri)
    http_delete(uri2)

    uri = "#{Sinatra::Application.settings.couchdb}/cncflora_test"
    uri2 = "#{ Sinatra::Application.settings.elasticsearch }/cncflora_test"
    http_delete(uri)
    http_delete(uri2)

    http_delete("#{Sinatra::Application.settings.couchdb}/vacro_123")
end
