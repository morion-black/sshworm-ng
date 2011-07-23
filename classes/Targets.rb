class Targets
    
    attr_reader :targets
    
    def initialize(config,options)
        @config = config
        @options = options.parse

    end
    
    def give
        if @options['group']
        	puts "No config entry for group #{@options['group']}" unless @config['Groups'][@options['group']]
        	@targets = @config['Groups'][@options['group']]
        else 
            puts "No targets given" unless @options['machines']
        	@targets = @options['machines']
        end
        puts "DEBUG: Targets: #{@targets}" if $DEBUG
        self.targets
    end
end