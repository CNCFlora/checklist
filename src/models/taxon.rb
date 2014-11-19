class Taxon
    attr_accessor :name, :age

    def initialize(name, age=0)
        @name, @age = name,age 
    end

    def name=(name)
        @name = name
    end

    def age=(age)
        @age = age
    end
end

taxon = Taxon.new("Bruno")
puts "name = #{taxon.name}"
puts "name = #{taxon.age}"


=begin
    def initialize(h)
        h.each {|k,v| send("#{k}=",v)}
    end
=end
