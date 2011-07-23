require "rubygems"
require "net/ssh"
require "net/ssh/gateway"

class SshSession
    
    def initialize(config, options, targets, commands)
        @config = config
        @options = options.parse
        @targets = targets.give
        @commands = commands.read
        @threads = []
        @ssh_options ={
        	    :port => @config['Global']['ssh_port'],
    		    :verbose => @config['Global']['debug_level'].to_sym,
    		    :auth_methods => %w(password keyboard-interactive),
    		    :password => @config['Global']['password']
        }
        @commands_proc = Proc.new { |session, hostname|
            @commands.each do |cmd|
                puts "DEBUG: Command: #{cmd}" if $DEBUG
                os = session.exec!("uname")
                output = self.exec(session,cmd,os.strip)
                puts "#{hostname}: #{output}"
            end
        }
    
    end

    def start
        @targets.each do |hostname|
            if self.use_gw?
                @threads << Thread.new {
                    self.via_gw do |jump_server|
                        jump_server.ssh(hostname, @config['Global']['login'], @ssh_options) do |session|
                            @commands_proc.call(session,hostname)
                        end
                    end
                }
            else
                @threads << Thread.new {
                    Net::SSH.start(hostname,@config['Global']['login'], @ssh_options) do |session|
                        @commands.each do |cmd|
       				        self.exec(session,cmd)
       			        end
       		        end
       		    }
       	    end
       	end
       	
       	@threads.each {|thread|
       	    thread.join
       	}
    end
    
    def via_gw
        jump_server = Net::SSH::Gateway.new(@config['Global']['jump_server'], @config['Global']['login'], @ssh_options)

	    puts "DEBUG: port forwarding ok" if $DEBUG

	    yield jump_server
    	    
    end

    def use_gw?
        @config['Global']['use_jump']
    end
    
    def exec(session,cmd,os)
        channel = session.open_channel do |channel|
            channel.request_pty do |ch, success|
              raise "Could not obtain pty (i.e. an interactive ssh session)" if !success
            end
            puts "DEBUG: OS:#{os.to_s}|" if $DEBUG
            cmd = self.is_sudo?(os,cmd)
            puts "DEBUG: #{cmd}" if $DEBUG
            channel.exec(cmd) do |ch, success|
              abort "could not execute command" unless success
              channel.on_data do |ch, data|
                if data == "admin?"
                  puts "DEBUG: Password request" if $DEBUG
                  channel.send_data "#{@config['Global']['password']}\n"
                else
                  channel[:result] ||= ""
                  channel[:result] << data
                end
              end

              channel.on_extended_data do |ch, type, data|
                raise "SSH command returned on stderr: #{data}"
              end
            end
          end

          # Nothing has actually happened yet. Everything above will respond to the
          # server after each execution of the ssh loop until it has nothing left
          # to process. For example, if the above recieved a password challenge from
          # the server, ssh's exec loop would execute twice - once for the password,
          # then again after clearing the password (or twice more and exit if the
          # password was bad)
          channel.wait

          return channel[:result].strip # it returns with \r\n at the end
    end   
    
    def is_sudo?(os,cmd)
        if @config['Global']['use_sudo']
            case os
            when 'FreeBSD', 'Linux'
                cmd = "sudo -p admin? #{cmd}"
            when 'SunOS'
                cmd = "pfexec #{cmd}"
            else
                puts "What is OS???"
            end
        end
        
        cmd
    end 
end