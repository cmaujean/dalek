require 'rubygems'
require 'irc'
require 'logger'
require 'rfile'

class Dalek 
  
  def initialize(name, server, port, realname, channels={'#dalek' => nil}, logfile=$stderr)
    @logger = Logger.new logfile
    @logger.info "Dalek Caan, Starting up."
    @irc = IRC.new(name, server, port, realname)
    IRCEvent.add_callback('')
    @channels = channels
    @triggers = ['doctor', 'rose', 'donna', 'dalek', 'caan' ]
    @quotes = RFile.new "realquotes.txt", true
    add_channels
    
    IRCEvent.add_callback('privmsg') do |event|
      @triggers.each do |t|
        if event.message.downcase.include? t
          @irc.send_message(event.channel, next_quote)
        end
      end
    end
  end
  
  def add_channels
    
    IRCEvent.add_callback('endofmotd') do |event| 

      @channels.each_pair do |channel, key|
        if @key.nil?
          @irc.add_channel(channel)
        else
          @logger.info IRCConnection.send_to_server("JOIN #{channel} #{key}")
          @irc.channels.push(channel)
        end
        @logger.info "Channel #{channel} added" 
      end
    end
  end
  
  def start
      @irc.connect
  end
  
  def stop
    @irc.disconnect
  end
  
  def next_quote
    @logger.info "pulling next quote"
    @quotes.randomline.split(':')[1]
  end
end

caan = Dalek.new('Dalek', 'irc.nogoodshits.net', 6667, 'Dalek Caan', {"#dalek-too" => "Ooof"})
caan.start
