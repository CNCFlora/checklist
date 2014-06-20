Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/mustache'
require "sinatra/reloader" if development?

require 'cncflora_commons'
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
config[:elasticsearch] = "#{config[:datahub_url]}/#{settings.db}"
config[:strings] = JSON.parse(File.read("src/locales/#{settings.lang}.json", :encoding => "BINARY"))
config[:services] = "#{config[:dwc_services_url]}/api/v1"
config[:base] = settings.base
set :elasticsearch, config[:elasticsearch]

puts "datahub = #{config[:datahub]}"
puts "couchdb = #{config[:couchdb]}"
puts "elasticsearch = #{config[:elasticsearch]}"
=begin
puts "datahub = #{config[:elasticsearch]}"
puts "datahub = #{config[:datahub]}"
puts "datahub = #{config[:datahub]}"
puts "datahub = #{config[:datahub]}"
puts "datahub = #{config[:datahub]}"
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

post '/login' do
    session[:logged] = true
    session[:user] = JSON.parse(params[:user])
    204
end

post '/logout' do
    session[:logged] = false
    session[:user] = false
    204
end

get "/" do
    "teste123"
end

get '/families' do    
    #docs = db.get_all()

=begin
    families = {}
    docs = db.view("recorte","by_species")
    docs.each do |doc|
        if families[ doc[:value][:family] ].nil?
            families[ doc[:value][:family] ] = []
        end
        families[ doc[:value][:family] ].push(doc)
    end
    puts docs
    exit
=end

    r = search("taxon","*")
    puts "r = #{r}" 
    exit
    r.each{|taxon|
        families.push taxon["family"]
    }

    view :families, {:families=>families.uniq.sort}
end
