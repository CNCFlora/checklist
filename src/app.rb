#!/usr/bin/env ruby
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/mustache'
require 'sinatra/reloader' if development?

require 'cncflora_commons'

setup '../config.yml'

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
    # Get all families of checklist.
    species = search("taxon","*:*")

    families = []

    species.each do |specie|
        families << specie["family"]
    end
    families = families.uniq.sort

    docs = []
    families.each do |family|
        doc = { "name"=>family, "species_amount"=>0 }
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
    family = params[:family]
    species = search("taxon","family:\"#{family}\"")
    species_by_family = []
    species.each do |specie|
        species_by_family << specie
    end
    docs = [ { "family"=>family,"species"=>species_by_family } ]
    view :edit, {:docs=>docs}
end


post "/insert/specie" do
    specie = URI.encode( params["specie"] )

    doc = http_get("#{settings.floradata}/api/v1/specie?scientificName=#{specie}")["result"]

    metadata = { 
        "type"=>"taxon", 
        "created"=>Time.now.to_i, 
        "modified"=>Time.now.to_i, 
        "creator"=>"#{session[:user]["name"]}", 
        "contributor"=>"#{session[:user]["name"]}", 
        "contact"=>"#{session[:user]["email"]}" 
    }

    if doc.has_key?("synonyms")
        synonyms = []
        doc["synonyms"].each{ |key|
            key["metadata"] = metadata 
            result = http_post( settings.couchdb, key ) 
            synonyms << { "id" => result["id"], "rev"=>result["rev"] }
        }
        doc.delete("synonyms")
        doc["synonyms"] = synonyms
    end

    doc["metadata"] = metadata
    doc = http_post( settings.couchdb, doc )
    redirect request.referrer
end

get "/delete/specie/:specie" do
    specie = params[:specie]
    specie = search("taxon","scientificNameWithoutAuthorship:\"#{specie}\"")[0]
    if specie.has_key?("synonyms")
        specie["synonyms"].each { |synonym|
            doc = http_delete("#{settings.couchdb}/#{synonym["id"]}?rev=#{synonym["rev"]}")
        }
    end
    doc = http_delete("#{settings.couchdb}/#{specie["id"]}?rev=#{specie["rev"]}")
    redirect request.referrer
end

