class Animal
  def come
    "comendo"
  end
end

class PatoNormal < Animal
  def faz_quack
    "Quack!"
  end
end

class PatoEstranho < Animal
  def faz_quack
    "Queck!"
  end
end

class CriadorDePatos
    def castigo(pato)
      pato.faz_quack
    end
end

pato_normal = PatoNormal.new
pato_estranho = PatoEstranho.new
c = CriadorDePatos.new
puts c.castigo(pato_normal)
puts c.castigo(pato_estranho)
#puts pato_normal.faz_quack
#puts pato_estranho.faz_quack
