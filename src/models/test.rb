require_relative 'entity'

data = {:name => "Bruno", :last_name=>"Giminiani", :data_birth => '20-12-1978', :address => {:street => "Sao Domingos", :number => 85}}
pessoa = Entity.new
pessoa.init(data,0)
puts pessoa.inspect
#puts pessoa.class

