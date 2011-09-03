require 'rubygems'
require 'irc'
require 'logger'
require 'rfile'

class Dalek 
  
  def initialize(name, server, port, realname, channels=['#dalek'], logfile=$stderr)
    @logger = Logger.new logfile
    @logger.info "Dalek Caan, Starting up."
    @irc = IRC.new(name, server, port, realname)
    IRCEvent.add_callback('')
    @channels = channels
    @logger.info "Channels = #{@channels.inspect}"
    @triggers = ['doctor', 'rose', 'dalek', 'caan', 'botcheck' ]
    @logger.info "Triggers = #{@triggers.inspect}"
    @quotes = RFile.new "realquotes.txt", true
    add_channels
    
    IRCEvent.add_callback('privmsg') do |event|
    
      # commands
      /^!(?<cmd>\w+)/ =~ event.message.downcase
      
      cmd == "triggers" and @irc.send_message(event.channel, "You will bear witness that my triggers include: #{@triggers.inspect}. Your human triggers reek of weakness and failure.")
      cmd == "end" and @irc.send_message(event.channel, "We are not ready yet, to teach these human beings, the law of the Daleks! However, we can reveal that there are #{@quotes.length} lines left in the cycle.")
      cmd == "cycle" and @irc.send_message(event.channel, "You are not worthy.")
      
      # triggers
      @triggers.each do |t|
        if event.message.downcase.include? t
          @irc.send_message(event.channel, next_quote)
        end
      end
    end
  end
  
  def add_channels
    
    IRCEvent.add_callback('endofmotd') do |event| 

      @channels.each do |channel|
        @irc.add_channel(channel)
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
