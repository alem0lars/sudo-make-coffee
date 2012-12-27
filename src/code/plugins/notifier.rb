module SudoMakeCoffee
  module Plugins
    class Notifier
      include Cinch::Plugin

      listen_to :connect, method: :on_connect

      def on_connect(m)
        subscriber = config[:subscriber]
        irc_chans_info = config[:irc_chans_info]

        subscriber.subscribe do |ipc_chan, msg|
          # INF: here i got a msg from an ipc channel
          @bot.channels.each do |irc_chan| # for each irc channels that the bot has joined
            irc_chan_info = Irc::ChannelInfo.lookup_name(irc_chans_info, irc_chan.to_s)
            # if the ipc channel where the message comes from is one of those
            #   that irc channel is interested, then compute the message,
            #   otherwise ignore the message
            if irc_chan_info.ipc_chans_assoc.index(ipc_chan)
              if msg.eql?(Ipc::Spec::Msgs.instance.quit) # there is a quit message for the bot
                @bot.part(irc_chan, 'I have to quit :( Bye bye')
              elsif msg.has_key?('kind') && (msg['kind'] == 'logging')
                irc_chan.send(msg['value'])
              end
            end
          end
        end
      end
    end
  end
end
