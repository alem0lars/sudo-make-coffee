module Irc
  class ChannelInfo
    attr_accessor :name, :ipc_chans_assoc

    def initialize(name, ipc_chans_assoc)
      @name, @ipc_chans_assoc = name, ipc_chans_assoc
    end

    def self.lookup_name(chans, name)
      chan_found = nil
      chans.each { |chan| chan_found = chan if chan.name == name }
      raise "name (#{name}) is not in chans (#{chans})" if chan_found.nil?
      chan_found # return
    end
  end
end
