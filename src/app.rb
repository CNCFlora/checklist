#!/usr/bin/env ruby
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/mustache'
require 'sinatra/reloader' if development?

require 'securerandom'
require_relative 'dao/taxon'
require_relative 'utils/conf'



conf = Conf.new
#config_file '../config.yml'
conf.setup '../config.yml'

dao = TaxonDAO.new
puts "########## dao.scientificName =#{dao.scientificName} ##########"
puts dao.test "module"


def require_logged_in
    redirect('/') unless is_authenticated?
end
 
def is_authenticated?
    return !!session[:logged]
end

def view(page,data)
    @config = settings.config
    @session_hash = {:logged => session[:logged] || false, :user => session[:user] || '{}'}
    if session[:logged] 
        session[:user]['roles'].each do | role |
            @session_hash["role-#{role['role'].downcase}"] = true
        end
    end
    mustache page, {}, @config.merge(@session_hash).merge(data)
end


post '/login' do
    session[:logged] = true
    preuser = JSON.parse(params[:user])
    user = http_get("#{settings.connect}/api/token?token=#{preuser["token"]}")
    session[:user] = user
    204
end

post '/logout' do
    session[:logged] = false
    session[:user] = false
    204
end

get "/" do
    #---------------------------------------
    taxons = dao.search("taxon","taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
    puts "taxons = #{taxons}"
    #---------------------------------------
    # Get all families of checklist.
    species = search("taxon","taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
    puts "----"
    puts "species = #{species}"
    puts "----"

    puts "specie[0] = #{species[0]}"

    families = []

    species.each do |specie|
        families << specie["family"]
    end
    families = families.uniq.sort

    docs = []
    families.each do |family|
        doc = { "name"=>family.upcase, "species_amount"=>0 }
        items = species.select{ |specie| specie["family"] == family }
        items.each do |specie|
            doc["species_amount"] += 1
        end
        docs << doc
    end

    families = docs
    view :index, {:families=>families}
end


get "/edit/family/:family" do
    require_logged_in

    # Get taxon by family
    family = params[:family].upcase
    species = search("taxon","family:\"#{family}\" AND taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
    species_by_family = []
    species.each do |specie|
        synonyms = search("taxon", "taxonomicStatus:\"synonym\" AND acceptedNameUsage:\"#{specie["scientificNameWithoutAuthorship"]}*\"")
        # Check synonyms in specie
        specie["synonyms"] = [] if synonyms.size > 0
        synonyms.each do |synonym|
            specie["synonyms"] << { "scientificNameWithoutAuthorship" => synonym["scientificNameWithoutAuthorship"] } 
        end
        species_by_family << specie
    end
    species_by_family = species_by_family.sort_by { |element| element["scientificNameWithoutAuthorship"]}
    docs = [ { "family"=>family,"species"=>species_by_family } ]
    view :edit, {:docs=>docs}
end


post "/insert/specie" do
    require_logged_in

    specie = URI.encode( params["specie"] )

    doc = http_get("#{settings.floradata}/api/v1/specie?scientificName=#{specie}")["result"]

    # Verify if the specie already exists.
    result = http_get( "#{settings.couchdb}/#{doc["taxonID"]}?include_docs=false")

    if result["error"]
        metadata = { 
            "id"=>doc["taxonID"],
            "type"=>"taxon", 
            "created"=>Time.now.to_i, 
            "modified"=>Time.now.to_i, 
            "creator"=>"#{session[:user]["name"]}", 
            "contributor"=>"#{session[:user]["name"]}", 
            "contact"=>"#{session[:user]["email"]}" 
        }

        if doc.has_key?("synonyms")
            doc["synonyms"].each{ |key|
                key["metadata"] = metadata 
                result = http_post( settings.couchdb, key ) 
            }
        end

        doc["metadata"] = metadata
        doc["_id"] = doc["taxonID"]
        doc = http_post( settings.couchdb, doc )
    end

    redirect request.referrer
end

post "/insert/new" do
    require_logged_in

    if !params.has_key?("family") || !params.has_key?("scientificNameWithoutAuthorship") || !params.has_key?("scientificNameAuthorship") || !params.has_key?("taxonomicStatus")
        return 400, "Missing data #{params}"
    else
        params["scientificName"]="#{params[ "scientificNameWithoutAuthorship" ]} #{params["scientificNameAuthorship"]}"
        if params["taxonomicStatus"] == 'synonym' && !params.has_key?("acceptedNameUsage")
            return 400, "Missing accepted name #{params}"
        else
            if params["taxonomicStatus"]=='accepted' 
                params["acceptedNameUsage"] = params["scientificName"]
            end
            id = SecureRandom.uuid
            doc = {
                "taxonID"=>id,
                "scientificName"=>params["scientificName"],
                "scientificNameWithoutAuthorship"=>params["scientificNameWithoutAuthorship"],
                "scientificNameAuthorship"=>params["scientificNameAuthorship"],
                "family"=>params["family"],
                "taxonRank"=>params["taxonRank"],
                "taxonomicStatus"=>params["taxonomicStatus"],
                "acceptedNameUsage"=>params["acceptedNameUsage"],
                "metadata" => { 
                    "identifier"=>id,
                    "type"=>"taxon", 
                    "created"=>Time.now.to_i, 
                    "modified"=>Time.now.to_i, 
                    "creator"=>"#{session[:user]["name"]}", 
                    "contributor"=>"#{session[:user]["name"]}", 
                    "contact"=>"#{session[:user]["email"]}" 
                }
            }
            r = http_post(settings.couchdb,doc)
            redirect request.referrer
        end
    end
end

get "/delete/specie/:specie" do
    require_logged_in

    specie = params[:specie]
    specie = search("taxon","scientificNameWithoutAuthorship:\"#{specie}\"")[0]

    q = "taxonomicStatus:\"synonym\" AND acceptedNameUsage:\"#{specie["scientificNameWithoutAuthorship"]}*\""
    synonyms = search("taxon", q)

    synonyms.each { |synonym|
        doc = http_delete("#{settings.couchdb}/#{synonym["id"]}?rev=#{synonym["rev"]}")
    }

    doc = http_delete("#{settings.couchdb}/#{specie["id"]}?rev=#{specie["rev"]}")
    redirect request.referrer
end

get "/search/accepted" do
    content_type :json
    search("taxon","scientificName:\"#{params["query"]}*\"").to_json
end

