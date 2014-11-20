# To do
# conversion charset. Ex.: São Domingos and Joana D'Arc.

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

#data = {:name => "Bruno", :last_name=>"Giminiani", :data_birth => '20-12-1978', :address => {:street => "Sao Domingos", :number => 85}}
#pessoa = Entity.new
#pessoa.init(data,0)
#puts pessoa.inspect
#puts pessoa.class
