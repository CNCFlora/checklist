require_relative '../utils/cncflora_commons'

class TaxonDAO
    include CNCFlora_Commons

    attr_accessor :datahub, :database, :type
    def initialize(datahub,database)        
        @datahub = datahub
        @database = database
        @type = "taxon"
    end


    def get_taxons
        #str = "#{self.datahub,'"#{self.type}"',""}"
        search(self.datahub,self.database,self.type,"taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
    end


    def get_species
        species = search(self.datahub,self.database,self.type,"taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
    end

    


=begin
    def get_taxons_by_family(family)
        search("taxon","family:\"#{family}\" AND taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
    end

    def add_specie(specie)
    end
=end    
end
