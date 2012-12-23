module Ipc

  class Publisher
    attr_accessor :db, :ipc_chan

    def initialize(db, ipc_chan)
      @db, @ipc_chan = db, ipc_chan
    end

    def publish(msg)
      @db.conn.publish(@ipc_chan.name, @ipc_chan.encode(msg))
    end

  end

end
