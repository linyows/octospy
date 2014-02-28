require 'octospy/recordable/channel'

module Octospy
  module Recordable
    class << self
      def channels
        @channels ||= []
      end

      def channels_include?(name)
        !!find_channel(name)
      end

      def find_channel(name)
        channels.find { |channel| channel.name.to_s == name.to_s }
      end

      def add_channel(name)
        channels << Channel.new(name) unless channels_include? name
      end

      def remove_channel(name)
        channels.delete_if { |channel| channel.name.to_s == name.to_s }
      end

      def channel(name)
        if channels_include? name
          find_channel name
        else
          Channel.new(name)
        end
      end
    end
  end
end
