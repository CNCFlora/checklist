{
	"type":"object",
	"properties": {
        "metadata": {
            "type":"object",
            "required":true
        },
        "taxon": {
            "type": "object",
            "properties": {
                "family":{"type":"string"},
                "scientificName":{"type":"string"},
                "scientificNameAuthorship":{"type":"string"},
                "lsid":{"type":"string"}
            }
        }
    },
    "required": ["metadata","taxon"]
}
