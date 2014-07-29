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

setup '../config.yml'

describe "Web app" do


    before(:each) do
        post "/login", { :user=>'{"name":"Bruno","email":"bruno@cncflora.net"}' }
    end

    it "Can insert specie" do
        specie_without_synonym = "Aphelandra acrensis"
        specie_with_synonym = "Aphelandra blanchetiana"
        doc = http_get("http://192.168.50.16:49155/api/v1/specie?scientificName=#{URI.encode(specie_without_synonym)}")["result"]
        #doc = http_get("#{settings.flora}/api/v1/search/species?query=Aphelandra blanchetiana")
        puts "doc - #{doc}"
        post "/insert/specie", { "specie" => doc["scientificNameWithoutAuthorship"] }
        last_response.status.should eq(302)
        sleep 2
        get "/"
        last_response.body.should have_tag( "a", with: { href: "/edit/family/ACANTHACEAE"} )
    end
end
