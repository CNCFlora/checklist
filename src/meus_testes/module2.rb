
module Module2

=begin
    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
    end
=end

    def hello2(msg="Module 2")
        "Module2 says hellow world #{msg}"
    end

end
