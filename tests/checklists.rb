
require_relative 'base'

describe "Creation of checklists" do

    before(:each) do
      post "/login", { :user=>'{"name":"Bruno","email":"bruno@cncflora.net"}'}
      before_each()
    end

    after(:each) do
      after_each()
    end

    it "List checklists" do
      get "/"
      expect(last_response.body).to have_tag('a',:text=>'CNCFLORA')
      expect(last_response.body).to have_tag('a',:text=>'CNCFLORA TEST')
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
end
