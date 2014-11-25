require 'rubygems'
require 'json'
require 'json-schema'

class Test
    attr_accessor :data

=begin
    def data
        @data
    end

    def data=(data)
        @data = data
    end
=end

    def initialize(hash)
        hash.each do |k,v|
            self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
            self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
            self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
        end
    end
=begin
h.each { |k,v|
    instance_variable_set("@#{k}",v)
    puts "k: #{k} and #{instance_variables.map(&method(:instance_variable_get))}"
    class_eval { attr_accessor attr }
    instance_variable_set "@#{attr}", v            
    create_attr(k)            
        }
    end
=end

    def validate_data
      self.data.is_a? Hash
    end

    def puts_data
        puts self.data      
    end



end
=begin
person = '{ "name":"Bruno", "last_name":"Giminiani", "data_birth":"20-12-1978", "address":{ "street":"Sao Domingos", "number":85 } }'
person_hash = JSON.load(person)
puts "1 - person=#{person}"

person = Test.new person_hash
puts "instance_variables: #{person.instance_variables}"
puts "name of person: #{person.name}"
=end
h1 = {"foo"=>"bar"}
h2 = {"name"=>"Bruno"}
test = Test.new h1
test.data = h2
test.validate_data
puts test.validate_data
#puts test.data.validate_data
