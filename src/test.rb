require_relative 'models/taxon'
species = [
    {
        "taxonID"=>"21640", 
        "family"=>"Acanthaceae", 
        "genus"=>"Aphelandra", 
        "scientificName"=>"Aphelandra aurantiaca (Scheidw.) Lindl.", 
        "scientificNameAuthorship"=>"(Scheidw.) Lindl.", 
        "scientificNameWithoutAuthorship"=>"Aphelandra aurantiaca", 
        "taxonomicStatus"=>"accepted", 
        "acceptedNameUsage"=>"Aphelandra aurantiaca (Scheidw.) Lindl.", 
        "taxonRank"=>"species", 
        "higherClassification"=>"Acanthaceae;Aphelandra;Aphelandra aurantiaca", 
        "synonyms"=>[], 
        "metadata"=>
            {
                "id"=>"21640", 
                "type"=>"taxon", 
                "created"=>1415373144, 
                "modified"=>1415373144, 
                "creator"=>"Bruno", 
                "contributor"=>"Bruno", 
                "contact"=>"bruno@cncflora.net"
            },
        "id"=>"21640", 
        "rev"=>"1-721efe6ea4b9ff9b78e2477e279743e7"
    }
]
specie = species[0]
puts "specie = #{specie}"
puts "specie.class = #{specie.class}"
taxon = Taxon.new(specie)
puts "taxon.family = #{taxon.family}"
