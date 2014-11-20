require 'json'
require 'json-schema'


class Entity
 #attr_reader :datetime, :duration, :class, :price, :level

    def init(data, recursion)
        data.each do |name, value|
            if value.is_a? Hash
                init(value, recursion+1)
            else
                instance_variable_set("@#{name}", value)
                #bit missing: attr_accessor name.to_sym 
            end
        end
    end        
end
my_hash = JSON.parse('{"hello": "goodbye"}')
#puts my_hash["hello"] => "goodbye"
puts my_hash["hello"]

schema = '{
    "person": {
        "type": "object",
        "required":["last_name"],
        "additionalProperties": false,
        "properties": {
            "name": {
                "type": "string"
            },
            "last_name": {
                "type": "string",
                "required": true
            },
            "data_birth": {
                "type": "string"
            },
            "address": {
                "type": "object",
                "required": false,
                "properties": {
                    "street": {
                        "type": "string"
                    },
                    "number": {
                        "type": "number"
                    }
                 }
            }
        }
    }
}'

person = '{ "name":"Bruno", "test":"", "data_birth":"20-12-1978", "address":{"street":"Sao Domingos", "number":85}}'

puts "core schema_json =  #{schema}"
puts "core person_json = #{person}"
schema = JSON.load(schema)
person = JSON.load(person)
puts "JSON.load(schema) = #{schema}"
puts "JSON.load(schema) = #{person}"
#person = {"name" => "Bruno", "test"=>nil, "data_birth" => "20-12-1978", "address" => {"street" => "Sao Domingos", "number" => 85}}
#puts "schema = #{schema}"
#puts "person = #{person}"
puts "validate = #{JSON::Validator.validate!(schema,person)}"
=begin
=end
# To do
# conversion charset. Ex.: São Domingos and Joana D'Arc.
# check field date on metadata schema.   