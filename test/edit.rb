
require_relative 'base'

describe "Edition of checklist" do

    before(:each) do
        post "/login", { :user=>'{"name":"Bruno","email":"bruno@cncflora.net"}' }
    end

    before(:all) do
        @specie_with_synonym = { "specie" => "Aphelandra blanchetiana", "synonyms" => [ "Aphelandra clava","Strobilorhachis blanchetiana" ] }     
    end

    it "Inserts specie without synonym" do
        post "/cncflora_test/insert/specie", { "specie" => "Aphelandra acrensis" }
        expect( last_response.status ).to eq(302)
        get "/cncflora_test"
        expect( last_response.body ).to have_tag( "td", :text => "ACANTHACEAE / 1")
        get "/cncflora_test/edit/family/ACANTHACEAE"
        expect( last_response.body ).to have_tag( "td", :text => "Aphelandra acrensis" )
        get "/cncflora_test/delete/specie/#{URI.escape( "Aphelandra acrensis" )}"
        get "/cncflora_test/edit/family/ACANTHACEAE"
        expect( last_response.body ).not_to have_tag( "td", :text => "Aphelandra acrensis" )
    end

    it "Inserts specie with synonym" do
        post "/cncflora_test/insert/specie", { "specie"=> "Aphelandra blanchetiana" }
        expect( last_response.status ).to eq(302)
        get "/cncflora_test"
        expect( last_response.body ).to have_tag( "td", :text => "ACANTHACEAE / 1")
        get "/cncflora_test/edit/family/ACANTHACEAE"
        expect( last_response.body ).to have_tag("td", :text => "Aphelandra blanchetiana" )
        expect( last_response.body ).to have_tag("td", :text => "Aphelandra clava" )
        expect( last_response.body ).to have_tag("td", :text => "Strobilorhachis blanchetiana" )
        get "/cncflora_test/delete/specie/#{URI.escape("Aphelandra blanchetiana")}"
        get "/cncflora_test/edit/family/ACANTHACEAE"
        expect( last_response.body ).not_to have_tag("td", :text => "Aphelandra blanchetiana" )
        expect( last_response.body ).not_to have_tag("td", :text => "Aphelandra clava" )
        expect( last_response.body ).not_to have_tag("td", :text => "Strobilorhachis blanchetiana" )
    end


    end
