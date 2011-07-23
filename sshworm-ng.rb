#!/usr/bin/env ruby

require "classes/SshSession"
require "classes/WormConfig"
require "classes/Commands"
require "classes/Options"
require "classes/Targets"

WORM_VER = "0.2.1 Alpha"
WORM_AUTHORS = "vivus-ignis & InViZz"

################################################################################
puts ""
puts " @@@@@@    @@@@@@   @@@  @@@  @@@  @@@  @@@   @@@@@@   @@@@@@@   @@@@@@@@@@   "
puts "@@@@@@@   @@@@@@@   @@@  @@@  @@@  @@@  @@@  @@@@@@@@  @@@@@@@@  @@@@@@@@@@@  "
puts "!@@       !@@       @@!  @@@  @@!  @@!  @@!  @@!  @@@  @@!  @@@  @@! @@! @@!  "
puts "!@!       !@!       !@!  @!@  !@!  !@!  !@!  !@!  @!@  !@!  @!@  !@! !@! !@!  "
puts "!!@@!!    !!@@!!    @!@!@!@!  @!!  !!@  @!@  @!@  !@!  @!@!!@!   @!! !!@ @!@  "
puts " !!@!!!    !!@!!!   !!!@!!!!  !@!  !!!  !@!  !@!  !!!  !!@!@!    !@!   ! !@!  "
puts "     !:!       !:!  !!:  !!!  !!:  !!:  !!:  !!:  !!!  !!: :!!   !!:     !!:  "
puts "    !:!       !:!   :!:  !:!  :!:  :!:  :!:  :!:  !:!  :!:  !:!  :!:     :!:  "
puts ":::: ::   :::: ::   ::   :::   :::: :: :::   ::::: ::  ::   :::  :::     ::   "
puts ":: : :    :: : :     :   : :    :: :  : :     : :  :    :   : :   :      :    "
puts ""
puts "#{WORM_VER} by #{WORM_AUTHORS}"
puts ""
puts "------------------------------------------------------------------------------"
################################################################################
$DEBUG = false

config = WormConfig.instance.read('config.yml')
options = Options.new
targets = Targets.new(config,options)
commands = Commands.new

ssh_session = SshSession.new(config, options, targets, commands)
ssh_session.start