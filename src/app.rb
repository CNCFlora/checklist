#!/usr/bin/env ruby
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/mustache'
require 'sinatra/reloader' if development?

require 'securerandom'

require 'cncflora_commons'

setup 'config.yml'

def require_logged_in
    redirect("#{settings.base}/?back_to=#{request.path_info}") unless is_authenticated?
end
 
def is_authenticated?
    return !!session[:logged]
end

def view(page,data)
    @config = settings.config
    @session_hash = {:logged => session[:logged] || false, :user => session[:user] || {}, :user_json => session[:user].to_json }

    if data[:db]
      data[:db_name] = data[:db].gsub('_',' ').upcase
    end

    mustache page, {}, @config.merge(@session_hash).merge(data)
end


post '/login' do
    session[:logged] = true
    preuser = JSON.parse(params[:user])
    #user = http_get("#{settings.connect}/api/token?token=#{preuser["token"]}")
    session[:user] = preuser
    204
end

post '/logout' do
    session[:logged] = false
    session[:user] = false
    204
end

get "/" do
  if session[:logged] && params[:back_to] then
    redirect "#{settings.base}#{ params[:back_to] }"
  elsif session[:logged] then
    dbs=[]
    all=http_get("#{ settings.couchdb }/_all_dbs")
    all.each {|db|
      if db[0] != "_" && !db.match('_history') then
        dbs << {:name=>db.gsub("_"," ").upcase,:db =>db}
      end
    }
    view :index,{:dbs=>dbs}
  else
    view :index,{:dbs=>[]}
  end
end

post "/" do
  if params[:db].gsub(" ","_").match('^[a-zA-Z0-9_]+$') then
    http_put("#{settings.couchdb}/#{params[:db].gsub(" ","_").downcase}",{})
    http_put("#{settings.elasticsearch}/#{params[:db].gsub(" ","_").downcase}",{})
  end
  redirect("#{settings.base}/");
end

get "/:db" do
    # Get all families of checklist.
    species = search(params[:db],"taxon","taxonomicStatus:\"accepted\"")

    families = []

    species.each do |specie|
        families << specie["family"]
    end
    families = families.uniq.sort

    docs = []
    families.each do |family|
        doc = { "name"=>family.upcase, "species_amount"=>0 }
        doc["species_amount"] = species.select{ |specie| specie["family"].upcase == family.upcase }.count
        docs << doc
    end

    families = docs
    view :families, {:families=>families,:db=>params[:db]}
end


get "/:db/edit/family/:family" do
    require_logged_in

    # Get taxon by family
    family = params[:family].upcase
    species = search(params[:db],"taxon","family:\"#{family}\" AND taxonomicStatus:\"accepted\"")
    species_by_family = []
    species.each do |specie|
        specie["synonyms"] = search(params[:db],"taxon", "taxonomicStatus:\"synonym\" AND acceptedNameUsage:\"#{specie["scientificNameWithoutAuthorship"]}*\"").sort_by { |element| element["scientificNameWithoutAuthorship"]}
        species_by_family << specie
    end
    species_by_family = species_by_family.sort_by { |element| element["scientificNameWithoutAuthorship"]}
    docs = [ { "family"=>family,"species"=>species_by_family } ]
    view :edit, {:docs=>docs,:db=>params[:db]}
end

post "/:db/insert/new" do
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
                "_id"=>id,
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
                    "contact"=>"#{session[:user]["email"]}",
                    "source"=>"User"
                }
            }
            r = http_post("#{ settings.couchdb }/#{params[:db]}",doc)
            index(params[:db],doc)
            redirect request.referrer
        end
    end
end

get "/:db/delete/specie/:specie" do
    require_logged_in

    specie = params[:specie]
    specie = search(params[:db],"taxon","scientificNameWithoutAuthorship:\"#{specie}\"")[0]

    q = "taxonomicStatus:\"synonym\" AND acceptedNameUsage:\"#{specie["scientificNameWithoutAuthorship"]}*\""
    synonyms = search(params[:db],"taxon", q)

    synonyms.each { |synonym|
      doc = http_delete("#{settings.couchdb}/#{params[:db]}/#{URI.encode( synonym["id"] )}?rev=#{synonym["rev"]}")
      http_delete("#{settings.elasticsearch}/#{params[:db]}/taxon/#{URI.encode( synonym["id"] )}")
    }

    doc = http_delete("#{settings.couchdb}/#{params[:db]}/#{URI.encode(specie["id"])}?rev=#{specie["rev"]}")
    http_delete("#{settings.elasticsearch}/#{params[:db]}/taxon/#{URI.encode(specie["id"])}")
    sleep 1
    redirect request.referrer
end

get "/:db/search/accepted" do
    content_type :json
    search(params[:db],"taxon","scientificName:\"#{params["query"]}*\" taxonomicStatus:\"accepted\"").to_json
end

post "/:db/insert/specie" do
  require_logged_in

  specie = URI.encode( params["specie"] )

  doc = http_get("#{settings.floradata}/api/v1/specie?scientificName=#{specie}")["result"]

  # Verify if the specie already exists.
  result = http_get( "#{settings.couchdb}/#{params[:db]}/#{doc["taxonID"]}?include_docs=false")

  if result["error"]

    metadata = { 
      "identifier"=>doc["taxonID"],
      "type"=>"taxon", 
      "created"=>Time.now.to_i, 
      "modified"=>Time.now.to_i, 
      "creator"=>"#{session[:user]["name"]}", 
      "contributor"=>"#{session[:user]["name"]}", 
      "contact"=>"#{session[:user]["email"]}" ,
      "source"=> doc["source"]
    }

    if doc.has_key?("synonyms")
    doc["synonyms"].each{ |syn|
      syn["_id"] = syn["taxonID"]
      syn["metadata"] = metadata.clone
      result = http_post( "#{ settings.couchdb }/#{params[:db]}", syn ) 
      index(params[:db],syn)
    }
    end

    doc["metadata"] = metadata
    doc["_id"] = doc["taxonID"]
    r = http_post(  "#{ settings.couchdb }/#{params[:db]}", doc )
    index(params[:db],doc)
  end

  redirect request.referrer
end
