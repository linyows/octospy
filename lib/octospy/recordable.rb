require 'octospy/recordable/channel'
require 'octospy/recordable/repo'

module Octospy
  module Recordable
    def channels
      @channels ||= {}
    end

    def add_channel(name)
      @channels.merge!(:"#{name}" => Channel.new(name)) unless channels.has_key?(name.to_sym)
    end

    def del_channel(name)
      @channels.delete(name.to_sym) if channels.has_key?(name)
    end

    def channel(name)
      if channels.has_key?(name.to_sym)
        @channels[name.to_sym]
      else
        Channel.new(name)
      end
    end
  end
end
