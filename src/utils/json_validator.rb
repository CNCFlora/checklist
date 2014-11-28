require 'rubygems'
require 'json'
require 'json-schema'

class JsonValidator
    attr_accessor :schema, :data

    def initialize(schema='{}',data={})
        @schema = schema
        @data = data
    end

    def validate_json_schema(schema,hash)
        begin
            JSON::Validator.validate!(schema, hash)
        rescue JSON::Schema::ValidationError
          puts $!.message
        end
    end

    def validate_data
        self.data.is_a? Hash
    end

    def keys_data_to_sym(data)
        raise ArgumentError, "'data' is not a Hash." unless self.data.is_a? Hash
        "parsed"
    end

    #def keys_data_to_string(data)
    #end
  
end

test = JsonValidator.new
test.data = {"name"=>"João", "last_name"=>"Silva"}
puts test.validate_data
#test.data = 3
puts test.data
puts test.data.class
puts test.keys_data_to_sym test.data
