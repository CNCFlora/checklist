
require_relative 'base'

describe "Manual insertion of specie" do

    before(:each) do
        post "/login", { :user=>'{"name":"Bruno","email":"bruno@cncflora.net"}' }
    end

    it "Insert specie and synonym manually" do
        post "/cncflora_test/insert/new", {"scientificNameWithoutAuthorship"=>"Foo fuz","family"=>"Foaceae","taxonomicStatus"=>"accepted"}
        expect( last_response.status ).to eq( 400 )
        post "/cncflora_test/insert/new", {"scientificNameWithoutAuthorship"=>"Foo fuz","scientificNameAuthorship"=>"bar.","family"=>"Foaceae","taxonomicStatus"=>"accepted"}
        expect( last_response.status ).to eq( 302 )
        post "/cncflora_test/insert/new", {"scientificNameWithoutAuthorship"=>"Foo foo","scientificNameAuthorship"=>"bar.","family"=>"Foaceae","taxonomicStatus"=>"synonym"}
        expect( last_response.status ).to eq( 400 )
        post "/cncflora_test/insert/new", {"scientificNameWithoutAuthorship"=>"Foo foo","scientificNameAuthorship"=>"bar.","family"=>"Foaceae","taxonomicStatus"=>"synonym","acceptedNameUsage"=>"Foo fuz bar."}
        expect( last_response.status ).to eq( 302 )
        sleep 3
        get "/cncflora_test/edit/family/Foaceae"
        expect( last_response.body ).to have_tag( "span", :text => "Foo fuz" )
        expect( last_response.body ).to have_tag( "span", :text => "Foo foo" )
        get "/cncflora_test/delete/specie/Foo+fuz"
        sleep 2
        get "/cncflora_test/edit/family/Foaceae"
        expect( last_response.body ).not_to have_tag( "span", :text => "Foo fuz" )
        expect( last_response.body ).not_to have_tag( "span", :text => "Foo foo" )
    end

end

