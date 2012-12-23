module Ipc

  class Subscriber
    attr_accessor :db, :ipc_chans

    def initialize(db, ipc_chans)
      @db = db
      @ipc_chans = ipc_chans
    end

    def subscribe(&block)
      # channels map with:
      # - key -> channel name
      # - value -> channel object
      ipc_chans_map = Hash[@ipc_chans.collect { |ipc_chan| [ipc_chan.name, ipc_chan] }]
      # array of channel names
      ipc_chans_names = @ipc_chans.collect { |ipc_chan| ipc_chan.name }
      # subscribe into channels given from initialize, on each message call the block given as argument
      @db.conn.subscribe(*ipc_chans_names) do |on|
        on.message do |ipc_chan_name, msg|
          chan = ipc_chans_map[ipc_chan_name]
          block.call(chan, chan.decode(msg))
        end
      end
    end

  end

end
