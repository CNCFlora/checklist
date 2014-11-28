require_relative 'module1'
class Test
    include Module1
end

test = Test.new
puts test.hello1
