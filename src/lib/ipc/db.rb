require 'redis'


module Ipc
  class Db
    attr_accessor :conn, :nsid

    def initialize(host, port, nsid)
      @nsid = nsid
      @conn = Redis.new(:host => host, :port => port)
      @status = nil
    end

    def gen_key(key_name)
      "#{@nsid}:#{key_name}"
    end

    def execute
      result = @conn.multi { yield @conn }
      @status = !result[0].nil?
      result
    end

    def succeeded?
      !!@status
    end

  end
end
