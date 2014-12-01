require_relative '../utils/cncflora_commons'


class GenericDAO
    include CNCFlora_Commons
   

    attr_accessor  :datahub
    def initialize(datahub)
        @datahub = datahub
    end


    def query(type,query)
        search(self.datahub,type,query)
    end

    def get_taxons
        search(datahub,"taxon","taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
    end


    def get_species
        species = search("taxon","taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
    end

    
    #def search!()



=begin
    def get_taxons_by_family(family)
        search("taxon","family:\"#{family}\" AND taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
    end
    def add_specie(specie)
    end
=end
end
