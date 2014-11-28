class Conf
    include CNCFlora_Config
=begin
    attr_accessor :file

    def initialize(file)
        @file = file
    end

    setup @file
=end
end
