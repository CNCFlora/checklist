#require 'sinatra'
#require 'sinatra/config_file'
#require 'sinatra/mustache'
#require 'sinatra/reloader' if development?

#require 'securerandom'

require_relative '../utils/cncflora_commons'
require_relative '../utils/cncflora_config'

#config_file '../../config.yml'

class TaxonDAO
    include CNCFlora_Commons
   
    attr_accessor :scientificName
    def initialize(scientificName='scientificNameTest')
        @scientificName = scientificName
    end

=begin
    def get_taxons
        search("taxon","taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
        #"all_taxons"
    end

    def get_taxons_by_family(family)
        search("taxon","family:\"#{family}\" AND taxonomicStatus:\"accepted\" AND NOT taxonRank:\"family\"")
    end
    def add_specie(specie)
    end
=end
end
