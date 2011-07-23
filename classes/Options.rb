require "optparse"

class Options < Hash
    
    attr_reader :options
    
    def initialize
        @options = Hash.new

        @options['mode'] = 'log'
        @options['log'] = $stdout
        
    end
    
    def parse
        OptionParser.new do |opt|
#        	opt.banner = "sshworm, #{WORM_VER} by vivus-ignis feat InViZz"
        	opt.separator ""
        	opt.separator "Usage: #{File.basename(__FILE__)} <mode> <targets>"
        	opt.separator ""
        	opt.separator "Commands for remote execution should be fed to stdin:"
        	opt.separator "shell> echo 'uptime' | #{File.basename(__FILE__)} -m server1.domain.com"
        	opt.separator "shell> #{File.basename(__FILE__)} -g webservers < file_with_commands.txt"
        	opt.separator ""
        	opt.separator ""
        	opt.separator "Mode options:"
        	opt.separator "-------------"
        	opt.on('-i', '--interactive', 'Interactive mode') { |val| @options['mode'] = 'interactive' }
        	opt.on('-b', '--batch', 'Run all commands simultaneously') { |val| @options['mode'] = 'batch' }
        	opt.on('-d', '--diff', 'Diff compare output (for 2 machines only)') { |val| @options['mode'] = 'diff' }
        	opt.on('-y', '--yes', 'Answer yes to all interactive requests') { |val| @options['mode'] = 'yes' }
        	opt.on('-l', '--log [LOGFILE]', 'Log mode. Output will be logged to file. No argument is for logging to stdout') { |val| @options['mode'] = 'log'; @options['log'] = val }
        	opt.separator "default mode is --log STDOUT"
            opt.separator ""
            opt.separator "Target specifiers:"
        	opt.separator "------------------"
        	opt.on('-g', '--group GROUPNAME', 'Group from config') { |val| @options['group'] = val }
        	opt.on('-m', '--machine HOSTNAME_X,HOSTNAME_Y,HOSTNAME_Z', Array, 'Machine(s) from config')  { |val| @options['machines'] = val }
            opt.on('-r', '--regexp REGEXP','Regexp pattern for machines lookup in config') { |val| @options['regexp'] = val }
        	opt.separator "default is to run commands on all machines in config"
        	opt.separator ""
        	opt.on_tail('-h', '--help')           { puts opt; exit }

            opt.parse!
        end

        self.options
        
    end
    
end