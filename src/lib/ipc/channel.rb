require 'json'


module Ipc
  class Channel
    attr_accessor :name, :format

    def initialize(name, format = nil)
      @name = name
      @format = format
    end

    def decode(msg)
      case @format
        when 'json' then JSON.parse(msg)
        else msg
      end
    end

    def encode(msg)
      case @format
        when 'json' then msg.to_json
        else msg
      end
    end

    def self.lookup_name(chans, name)
      chan_found = nil
      chans.each { |chan| chan_found = chan if chan.name == name }
      raise "name (#{name}) is not in chans (#{chans})" if chan_found.nil?
      chan_found # return
    end

  end
end
