require "fcntl"

class Commands < Hash
    
    attr_reader :commands
    
    def initialize
        @commands = []
        
    end
    
    def read
        if STDIN.fcntl(Fcntl::F_GETFL, 0) == 0
    	    ARGF.each_line { |command|
    		    @commands.push(command)
    	    }
        else
    	    puts "No commands on stdin"
        end
        
        self.commands
    end
end