require 'uri'
require 'json'
require 'net/http'

module CNCFlora_HTTP

    def http_get(uri)
        JSON.parse(Net::HTTP.get(URI(uri)))
    end


    def http_post(uri,doc)
        uri = URI.parse(uri)
        http = Net::HTTP.new(uri.host, uri.port)

        if doc.class == Hash
            header = {'Content-Type'=> 'application/json'}
        elsif doc.class == String
            header = {'Content-Type'=> 'application/x-www-form-urlencoded'}
        end

        request = Net::HTTP::Post.new(uri.request_uri, header)

        if doc.class == Hash
            request.body = doc.to_json
        elsif doc.class == String
            request.body = doc
        end

        response = http.request(request)
        JSON.parse(response.body)
    end


    def http_put(uri,doc) 
        uri = URI.parse(uri)
        http = Net::HTTP.new(uri.host, uri.port)

        if doc.class == Hash
            header = {'Content-Type'=> 'application/json'}
        elsif doc.class == String
            header = {'Content-Type'=> 'application/x-www-form-urlencoded'}
        end

        request = Net::HTTP::Put.new(uri.request_uri, header)

        if doc.class == Hash
            request.body = doc.to_json
        elsif doc.class == String
            request.body = doc
        end

        response = http.request(request)

        JSON.parse(response.body)
    end


    def http_delete(uri)
        uri = URI.parse(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Delete.new(uri.request_uri)
        response = http.request(request)
        JSON.parse(response.body)
    end


end
