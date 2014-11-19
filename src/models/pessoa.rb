class Pessoa
    attr_accessor :required = []

    def initialize(data={})

        required.each{ |key|
            required_ = []
            if !(data.keys.include? key)
                required_ << key
            end
            if required_.size!=0 
                parameter_missing(required_)
            end
        }
        init(data,0)
    end

    #Create dynamically attributes.
    def init(data,recursion=0)
        data.each{ |name,value|
            if value.is_a? Hash
                init(value,recursion+1)
            end
            instance_variable_set("@#{name}",value)    
        }
    end


    def parameter_missing(parameter)
        raise Exception.new("Missing the followings required parameters #{parameter}")
    end
   
    
end

class PessoaDeVerdade
    attr_accessor :required = [:name,:age]
end

hash = {:name=>"Bruno",:last_name=>"Giminiani",:age=>36,:nationality=>"brazilian",:metadata=>{:type=>"person"}}
#pessoa = Pessoa.new {:name},hash
#hash = {:last_name=>"Giminiani",:age=>36,:nationality=>"brazilian",:metadata=>{:type=>"person"}}
required = {:name=>"Bruno"}
pessoa = Pessoa.new required,hash

puts "pessoa.attr = #{pessoa.instance_variables}"
puts "pessoa: #{pessoa.inspect}"
