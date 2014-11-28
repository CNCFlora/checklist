Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
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

http_get("#{ settings.couchdb }/cncflora_test/_all_docs")["rows"].each {|r|
  http_delete("#{settings.couchdb}/cncflora_test/#{r["id"]}?rev=#{r["value"]["rev"]}");
}
http_delete("#{settings.couchdb}/vacro_123")

describe "Web app" do

    before(:all) do

        @specie_without_synonym = "Aphelandra acrensis"
        @specie_with_synonym = { "specie" => "Aphelandra blanchetiana", "synonyms" => [ "Aphelandra clava","Strobilorhachis blanchetiana" ] }     
    end

    before(:each) do
        post "/login", { :user=>'{"name":"Bruno","email":"bruno@cncflora.net"}' }
    end

    it "List checklists" do
        get "/"
        expect( last_response.body ).to have_tag( "a", :text => "CNCFLORA TEST")
        expect( last_response.body ).to have_tag( "a", :text => "CNCFLORA")
    end

    it "Create checklist" do
      post "/", {"db"=>"Vaçroa 123#"}
      post "/", {"db"=>"Vaçroa 123"}
      post "/", {"db"=>"Vaçroa_123#"}
      post "/", {"db"=>"Vaçroa_12"}
      follow_redirect!
      expect( last_response.body ).to have_tag( "a", :text => "CNCFLORA TEST")
      expect( last_response.body ).to have_tag( "a", :text => "CNCFLORA")
      post "/", {"db"=>"Vacro 123"}
      follow_redirect!
      expect( last_response.body ).to have_tag( "a", :text => "CNCFLORA TEST")
      expect( last_response.body ).to have_tag( "a", :text => "CNCFLORA")
      expect( last_response.body ).to have_tag( "a", :text => "VACRO 123")
    end

    it "List families of checklist" do
        get "/cncflora_test"
        expect( last_response.body ).to have_tag( "span", :text => "Recorte: CNCFLORA TEST")
        expect( last_response.body ).to have_tag( "th", :text => "FAMÍLIAS")
    end

    it "Inserts specie without synonym" do
        post "/cncflora_test/insert/specie", { "specie" => @specie_without_synonym }
        expect( last_response.status ).to eq(302)
        sleep 2
        get "/cncflora_test"
        expect( last_response.body ).to have_tag( "a", with: { href: "/cncflora_test/edit/family/ACANTHACEAE"} )
        expect( last_response.body ).to have_tag( "td", :text => "ACANTHACEAE / 1")
        get "/cncflora_test/edit/family/ACANTHACEAE"
        expect( last_response.body ).to have_tag( "td", :text => @specie_without_synonym )
        expect( last_response.body ).to have_tag( "td", :with => { :class => 'species'} )
        get "/cncflora_test/delete/specie/#{URI.escape( @specie_without_synonym )}"
    end

    it "Inserts specie with synonym" do
        post "/cncflora_test/insert/specie", { "specie"=> @specie_with_synonym["specie"] }
        expect( last_response.status ).to eq(302)
        sleep 2
        get "/cncflora_test"
        expect( last_response.body ).to have_tag( "a", with: { href: "/cncflora_test/edit/family/ACANTHACEAE"} )
        get "/cncflora_test/edit/family/ACANTHACEAE"
        expect( last_response.body ).to have_tag( "td", :text => @specie_with_synonym["specie"] )
        expect( last_response.body ).to have_tag( "td", :with => { :class => 'species'} )
        (0..1).each do |i|
            expect( last_response.body ).to have_tag("td span", :text => @specie_with_synonym["synonyms"][i] )
        end
        get "/cncflora_test/delete/specie/#{URI.escape( @specie_with_synonym["specie"] )}"
    end

    it "Edits specie without synonym" do
        post "/cncflora_test/insert/specie", { "specie" => @specie_without_synonym }
        expect( last_response.status ).to eq( 302 )
        sleep 2
        get "/cncflora_test/edit/family/ACANTHACEAE"
        expect( last_response.body ).to have_tag( "td span", :text => @specie_without_synonym )
        get "/cncflora_test/delete/specie/#{URI.escape( @specie_without_synonym )}"
    end

    it "Edits specie with synonym" do
        post "/cncflora_test/insert/specie", { "specie" => @specie_with_synonym["specie"] }
        expect( last_response.status ).to eq( 302 )
        sleep 2
        get "/cncflora_test/edit/family/ACANTHACEAE"
        expect( last_response.body ).to have_tag( "td span", :text => @specie_with_synonym["specie"] )
        get "/cncflora_test/delete/specie/#{URI.escape( @specie_with_synonym["specie"] )}"
    end

    it "Delete specie without synonym" do
        post "/cncflora_test/insert/specie", { "specie" => @specie_without_synonym }
        expect( last_response.status ).to eq( 302 )
        sleep 2
        get "/cncflora_test/edit/family/ACANTHACEAE"
        expect( last_response.body ).to have_tag( "td span", :text => @specie_without_synonym )
        get "/cncflora_test/delete/specie/#{URI.escape( @specie_without_synonym )}"
        expect( last_response.status ).to eq(302)
        expect( last_response.body ).not_to have_tag( "td span", :tex => @specie_without_synonym )
    end

    it "Delete specie with synonym" do
        post "/cncflora_test/insert/specie", { "specie" => @specie_with_synonym["specie"] }
        expect( last_response.status ).to eq( 302 )
        sleep 2
        get "/cncflora_test/edit/family/ACANTHACEAE"
        expect( last_response.body ).to have_tag( "td span", :text => @specie_with_synonym["specie"] )
        (0..1).each do |i|
            expect( last_response.body ).to have_tag( "td span", :text => @specie_with_synonym["synonyms"][i] )
        end
        get "/cncflora_test/delete/specie/#{URI.escape( @specie_with_synonym["specie"] )}"
        expect( last_response.status ).to eq(302)
        expect( last_response.body ).not_to have_tag( "td span", :tex => @specie_with_synonym["specie"] )
        (0..1).each do |i|
            expect( last_response.body ).not_to have_tag( "td span", :text => @specie_with_synonym["synonyms"][i] )
        end
    end

    it "Insert specie manually" do
        post "/cncflora_test/insert/new", {"scientificNameWithoutAuthorship"=>"Foo fuz","family"=>"Foaceae","taxonomicStatus"=>"accepted"}
        expect( last_response.status ).to eq( 400 )
        post "/cncflora_test/insert/new", {"scientificNameWithoutAuthorship"=>"Foo fuz","scientificNameAuthorship"=>"bar.","family"=>"Foaceae","taxonomicStatus"=>"accepted"}
        expect( last_response.status ).to eq( 302 )
        post "/cncflora_test/insert/new", {"scientificNameWithoutAuthorship"=>"Foo foo","scientificNameAuthorship"=>"bar.","family"=>"Foaceae","taxonomicStatus"=>"synonym"}
        expect( last_response.status ).to eq( 400 )
        post "/cncflora_test/insert/new", {"scientificNameWithoutAuthorship"=>"Foo foo","scientificNameAuthorship"=>"bar.","family"=>"Foaceae","taxonomicStatus"=>"synonym","acceptedNameUsage"=>"Foo fuz bar."}
        expect( last_response.status ).to eq( 302 )
        sleep 2
        get "/cncflora_test/edit/family/Foaceae"
        expect( last_response.body ).to have_tag( "td span", :text => "Foo fuz" )
        expect( last_response.body ).to have_tag( "td span", :text => "Foo foo" )
        get "/cncflora_test/delete/specie/Foo+fuz"
        sleep 2
        get "/cncflora_test/edit/family/Foaceae"
        expect( last_response.body ).not_to have_tag( "td span", :text => "Foo fuz" )
        expect( last_response.body ).not_to have_tag( "td span", :text => "Foo foo" )
    end

end
