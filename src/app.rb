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

puts "elasticsearch = #{settings.elasticsearch}"
puts "config = #{config}"
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
    mustache :index, {}
end

get "/new_checklist" do
    mustache :new_checklist, {}
end

get "/edit_checklist" do
    mustache :edit_checklist, {}
end

get "/species" do
    mustache :species, {}
end

