require 'rubygems'
#require 'json'
#require 'json-schema'


class Entity

    def initialize(schema,hash)
        validate_json_schema(schema,hash)
        create_object(hash)
    end


    
    def create_object(hash)
        hash.each do |k,v|
            self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
            self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
            self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
        end
    end
    
end
my_hash = JSON.parse('{"hello": "goodbye"}')
#puts my_hash["hello"] => "goodbye"
puts my_hash["hello"]

=begin
schema = '{
        "type": "object",
        "additionalProperties": false,
        "required":["last_name"],
        "properties": {
            "name": {
                "type": "string"
            },
            "last_name": {
                "type": "string"
            },
            "data_birth": {
                "type": "string"
            },
            "address": {
                "type": "object",
                "required":["street"],
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
}'
=end

person = '{ "name":"Bruno", "last_name":"Giminiani", "data_birth":"20-12-1978", "address":{ "street":"Sao Domingos", "number":85 } }'

#puts "core schema_json =  #{schema}"
puts "core person_json = #{person}"
schema = JSON.load(IO.read("../../resources/schema/person.json"))
hash = JSON.load(person)
person = Entity.new schema, hash
puts "person.name = "
puts "person._instance_variables = #{person.instance_variables}"

#person = {"name" => "Bruno", "test"=>nil, "data_birth" => "20-12-1978", "address" => {"street" => "Sao Domingos", "number" => 85}}
#puts "schema = #{schema}"
#puts "person = #{person}"


#errors = JSON::Validator.validate!(schema,person)


schema = {
  "type" => "object",
    "required" => ["a"],
      "properties" => {
        "a" => {"type" => "integer"}
          }
}

data = {
  "b" => 5
}

#puts JSON::Validator.validate(schema, data)

hash = [1,"a"].inject({}) do |hash, item|
#[1,"a",Object.new,:hi].inject({}) do |hash, item|
  hash[item.to_s] = item
  hash
end
puts "hash = #{hash}"
=begin
=end
# To do
# conversion charset. Ex.: São Domingos and Joana D'Arc.
# check field date on metadata schema.   
