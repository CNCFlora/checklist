require_relative 'foo'

class Test
    include Math, Foo
    attr_accessor :numero, :home

    def initialize(num=0)
        @numero = num
        @home = ENV["HOME"]
    end

    def raiz(num)
        sqrt num
    end

    def get_taxons
        "all_taxons"        
    end

    def get_taxons_by_family(family)
        puts "taxons_by_family"
    end

end


test = Test.new 16
numero = test.numero
puts "numero = #{numero}"
puts "env = #{test.home}"
puts test.raiz numero
puts "test of Foo module: #{test.hello 'Bruno'}"
puts "get_taxons = #{test.get_taxons}"


