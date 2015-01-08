
require_relative 'base'

describe "Edition of checklist" do

    before(:each) do
        post "/login", { :user=>'{"name":"Bruno","email":"bruno@cncflora.net"}' }
    end

    before(:all) do
        @specie_without_synonym = "Aphelandra acrensis"
        @specie_with_synonym = { "specie" => "Aphelandra blanchetiana", "synonyms" => [ "Aphelandra clava","Strobilorhachis blanchetiana" ] }     
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

    end
