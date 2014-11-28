require_relative 'module2'
module Module1
    include Module2

    def hello1(msg="Module 1")
        msg_ = "Module1 says hellow world #{msg}"
        hello2 "#{msg} and Module 2"
    end
end
