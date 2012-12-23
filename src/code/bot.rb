require 'cinch'


module SudoMakeCoffee
  class Bot
    def initialize(server, irc_chans_info, db, ipc_chans)
      @bot = Cinch::Bot.new do
        configure do |c|
          c.server = server
          c.channels = irc_chans_info.collect { |irc_chan_info| irc_chan_info.name }
          c.plugins.plugins = [SudoMakeCoffee::Plugins::Notifier]
          c.plugins.options[SudoMakeCoffee::Plugins::Notifier] = {
            :subscriber => Ipc::Subscriber.new(db, ipc_chans),
            :irc_chans_info => irc_chans_info
          }
        end
      end
    end

    def start
      @bot.start
    end
  end
end
