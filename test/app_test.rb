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

    before(:all) do
        @specie_without_synonym = "Aphelandra acrensis"
        @specie_with_synonym = "Aphelandra blanchetiana"
    end

    before(:each) do
        post "/login", { :user=>'{"name":"Bruno","email":"bruno@cncflora.net"}' }
    end

    it "Go to home page" do
        get "/"
        expect( last_response.body ).to have_tag( "th", :text => "FAMÍLIAS")
    end

    it "Inserts specie without synonym" do
        doc = http_get("http://192.168.50.16:49155/api/v1/specie?scientificName=#{URI.encode(@specie_without_synonym)}")["result"]
        post "/insert/specie", { "specie" => doc["scientificNameWithoutAuthorship"] }
        expect( last_response.status ).to eq(302)
        sleep 2
        get "/"
        expect( last_response.body ).to have_tag( "a", with: { href: "/edit/family/ACANTHACEAE"} )
        expect( last_response.body ).to have_tag( "td", :text => "ACANTHACEAE / 1")
        get "/edit/family/ACANTHACEAE"
        expect( last_response.body ).to have_tag( "td", :text => @specie_without_synonym )
        expect( last_response.body ).to have_tag( "td", :with => { :id => 'species'} )
        get "delete/specie/#{URI.escape(@specie_without_synonym)}"
    end

    it "Inserts specie with synonym" do
        doc = http_get("http://192.168.50.16:49155/api/v1/specie?scientificName=#{URI.encode(@specie_with_synonym)}")["result"]
        synonyms = doc["synonyms"]
        #synonyms = search( "taxon", "taxonomicStatus:synonym AND acceptedNameUsage:\"#{specie_with_synonym}\"*")
        post "/insert/specie", { "specie"=> doc["scientificNameWithoutAuthorship"] }
        expect( last_response.status ).to eq(302)
        sleep 2
        get "/"
        expect( last_response.body ).to have_tag( "a", with: { href: "/edit/family/ACANTHACEAE"} )
        get "/edit/family/ACANTHACEAE"
        expect( last_response.body ).to have_tag( "td", :text => @specie_with_synonym )
        expect( last_response.body ).to have_tag( "td", :with => { :id => 'species'} )
        #synonyms.each do |synonym|
        #    expect( last_response.body ).to have_tag( "td#species", :text => "    #{synonym["scientificNameWithoutAuthorship"]} (synonym)" )
        #end
        (1..synonyms.size).each do |i|
            expect( last_response.body ).to have_tag( "td#species" )
        end
        get "delete/specie/#{URI.escape(@specie_with_synonym)}"
    end

    it "Edits specie without synonym" do
        post "/insert/specie", { "specie" => @specie_without_synonym }
        expect( last_response.status ).to eq(302)
        sleep 2
        get "/edit/family/ACANTHACEAE"
        expect( last_response.body ).to have_tag( "td", :text => @specie_without_synonym["scientificNameWithoutAuthorship"] )
        get "delete/specie/#{URI.escape(@specie_without_synonym)}"
    end

    it "Edits specie with synonym" do
        pending( "Not yet implemented." )
        this_should_not_get_executed
    end

end
