require_relative '../utils/cncflora_commons'
require_relative '../utils/json_utils'
require_relative '../models/entity'

class TaxonDAO
    include CNCFlora_Commons    
    include JSON_Utils

    @@schema_path = "/vagrant/resources/schema/taxon.json"
    attr_accessor :datahub, :database, :type, :schema
    def initialize(datahub,database)
        @datahub = datahub
        @database = database
        @type = "taxon"
        @schema = get_schema(@@schema_path)
    end


    def get_specie(specie)

        taxons = []
        data = search(self.datahub,self.database,self.type,"taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
        puts "/dao/taxon - data = #{data}"

        data.each{ |taxon|
            #puts "/dao/taxon - @schema = #{@schema}"
            #puts "/dao/taxon - taxon = #{taxon}"
            validate_json_schema(@schema,taxon)
            taxons.push(Entity.new(taxon)) 
        }
        taxons

    end



    def get_species
        species = []
        data = search(self.datahub,self.database,self.type,"taxonomicStatus:\"accepted\" AND taxonRank:\"family\"")
        data.each{ |specie|
            validate_json_schema(@schema,specie)
            species.push Entity.new(specie)
        }
        species
    end


    def insert(specie)
        http_post( "#{datahub}/#{database}", doc )
    end

    #def get_families
    #    families = search()
    #end

    

#schema = JSON.load(IO.read("../../resources/schema/person.json"))

=begin
    def get_taxons_by_family(family)
        search("taxon","family:\"#{family}\" AND taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
    end

    def add_specie(specie)
    end
=end    
end
