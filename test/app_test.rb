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

    it "Inserts specie without synonym" do
        specie_without_synonym = "Aphelandra acrensis"
        doc = http_get("http://192.168.50.16:49155/api/v1/specie?scientificName=#{URI.encode(specie_without_synonym)}")["result"]
        post "/insert/specie", { "specie" => doc["scientificNameWithoutAuthorship"] }
        expect( last_response.status ).to eq(302)
        sleep 2
        get "/"
        expect( last_response.body ).to have_tag( "a", with: { href: "/edit/family/ACANTHACEAE"} )
        get "/edit/family/ACANTHACEAE"
        expect( last_response.body ).to have_tag( "td", :text => specie_without_synonym )
        get "delete/specie/#{URI.escape(specie_without_synonym)}"
    end

    it "Inserts specie with synonym" do
        #specie_with_synonym = "Aphelandra blanchetiana"
        pending( "Not yet implemented." )
        this_should_not_get_executed
    end

end
