require "yaml"
require "singleton"

class WormConfig
    include Singleton

    attr_reader :config

    def initialize
        @config = Hash.new
    end

    def read(config)

        puts "Configfile (#{config}) not found" unless File.readable?(config)

        begin
        	@config = YAML.load_file(config)
        rescue Exception => errmsg
        	puts "Configfile format error: #{errmsg}"
        end

        self.config
    end

end