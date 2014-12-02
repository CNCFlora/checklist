require_relative 'cncflora_http'
require_relative 'cncflora_config'

module CNCFlora_Commons
    include CNCFlora_HTTP
    include Sinatra::CNCFlora_Config

    def search(elasticsearch,database,index,query)
        query="scientificName:'Aphelandra longiflora'" unless query != nil && query.length > 0
        result = []
        puts "query = #{query}"
        puts "uri = #{elasticsearch}/#{database}/#{index}/_search?size=999&q=#{URI.encode(query)}"
        r = http_get("#{elasticsearch}/#{database}/#{index}/_search?size=999&q=#{URI.encode(query)}")
        if r['hits'] && r['hits']['hits'] then
            r['hits']['hits'].each{|hit|
                result.push(hit["_source"])
            }
        else
            puts "search error #{r}"
        end
        result
    end

    def test(msg="test")
        "this is a #{msg}"
    end

end
