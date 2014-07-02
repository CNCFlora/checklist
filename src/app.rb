Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/mustache'
require "sinatra/reloader" if development?

require_relative 'cncflora_commons'
require 'couchdb_basic'

=begin
if development?
        also_reload "routes/*"
end
=end


config_file ENV['config'] || '../config.yml'
use Rack::Session::Pool
set :session_secret, '1flora2'
set :views, 'src/views'

config = etcd2settings(ENV["ETCD"] || settings.etcd)

config[:connect] = "#{config[:connect_url]}"
config[:datahub] = "#{config[:datahub_url]}"
config[:couchdb] = "#{config[:datahub_url]}/#{settings.db}"
#config[:elasticsearch] = "#{config[:datahub_url]}/#{settings.db}"
config[:elasticsearch] = "#{config[:datahub_url]}"
config[:strings] = JSON.parse(File.read("src/locales/#{settings.lang}.json", :encoding => "BINARY"))
config[:services] = "#{config[:dwc_services_url]}/api/v1"
config[:base] = settings.base
set :elasticsearch, config[:elasticsearch]

puts "config = #{config}"
checklists = "#{config[:datahub]}/checklists"
taxonomy = "#{config[:datahub]}/taxonomy"


#database = http_put("#{config[:datahub]}/test22222","")
#puts "http_put = #{database}"
=begin
puts "datahub = #{config[:datahub]}"
puts "couchdb = #{config[:couchdb]}"
puts "elasticsearch = #{config[:elasticsearch]}"
=end


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


get "/" do
    databases = http_get("#{checklists}/_all_docs?include_docs=true")
    databases = databases["rows"]
    view :index, {:databases=>databases}
end

get "/new" do
    mustache :new, {}
end

get "/delete/id/:_id/rev/:_rev" do
    http_delete("#{checklists}/#{params[:_id]}?rev=#{params[:_rev]}")
    databases = http_get("#{checklists}/_all_docs?include_docs=true")
    databases = databases["rows"]
    view :index, {:databases=>databases}
end

get "/edit/id/:_id/rev/:_rev" do
    doc = {}
    doc["_id"] = params["_id"]
    doc["_rev"] = params["_rev"]
    doc["metadata"] = {:type=>"checklist"}
    families = search("taxonomy","metadata.type=\"taxonomy\" AND taxonRank:\"family\"")
    families = families.sort_by {|f| f["family"]}
    doc["families"] = families
    view :edit, doc 
end

get "/edit/id/:_id/rev/:_rev/family/:family" do
    id = params[:_id]
    checklist = search("checklists","metadata.type=\"checklist\" AND _id:\"#{id}\"").first
    doc = {}
    doc["name"] = checklist["name"]
    doc["description"] = checklist["description"]
 
    puts "checklist = #{checklist}"

    species = search("taxonomy","metadata.type=\"taxonomy\" AND taxonRank:\"species\" AND family:\"#{params[:family]}\"")    
    puts "species = #{species}"
    view :edit, {}
end


post "/edit" do
    doc = {}
    doc["name"] = params["name"]
    doc["description"] = params["description"]
    doc["metadata"] = {:type=>"checklist"} 
    result = http_post("#{checklists}",doc)
    puts "result = #{result}"
    doc["_id"] = result["id"]
    doc["_rev"] = result["rev"]
    families = search("taxonomy","metadata.type=\"taxonomy\" AND taxonRank:\"family\"")
    families = families.sort_by {|f| f["family"]}
    doc["families"] = families
    view :edit, doc
end

=begin
post "/edit/id/:_id/rev/:_rev" do
    doc = {}
    doc["_id"] = params["_id"]
    doc["_rev"] = params["_rev"]
    doc["metadata"] = {:type=>"checklist"} 
    http_put("#{checklists}",doc)
    families = search("#{taxonomy}","metadata.type=\"taxonomy\" AND taxonRank=\"family\"")
    doc["families"] = families
    view :edit, doc
end
=end

get "/species" do
    mustache :species, {}
end

