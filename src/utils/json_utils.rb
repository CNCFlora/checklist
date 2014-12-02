require 'rubygems'
require 'json'
require 'json-schema'

module JSON_Utils
=begin
    attr_accessor :schema, :data

    def initialize(schema='{}',data={})
        @schema = schema
        @data = data
    end
=end

    def get_schema(file)
        puts "file json = #{file}"
        JSON.load(IO.read(file))
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

=begin
test = JsonValidator.new
test.data = {"name"=>"João", "last_name"=>"Silva"}
puts test.validate_data
#test.data = 3
puts test.data
puts test.data.class
puts test.keys_data_to_sym test.data
=end
