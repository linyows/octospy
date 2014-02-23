require 'cinch/plugins/octospy/recording'
require 'cinch/plugins/octospy/job'

module Cinch
  module Plugins
    class Octospy
      include Cinch::Plugin
      include Octospy::Recording
      include Octospy::Job

      set :prefix, ->(m) { %r(^#{Regexp.escape "#{m.bot.nick}: "}) }

      match(/hello|hi|hey/, method: :greet)
      match('ping', method: :pong)
      match('rename', method: :rename)
      match(/join (.+)/, method: :join)
      match(/part(?: (.+))?/, method: :part)
      match(/show status/, method: :show_status)
      match(/show commands/, method: :show_commands)

      listen_to :invite, method: :join_on_invite

      def greet(m)
        m.reply "hi #{m.user.nick}"
      end

      def pong(m)
        m.reply "#{m.user.nick}: pong"
      end

      def rename(m)
        @bot.nick += '_'
      end

      def join(m, channel)
        ch = "##{channel.gsub('#', '')}"
        Channel(ch).join
        m.reply "#{ch} joined!"
      end

      def part(m, channel)
        channel ||= m.channel
        if channel
          ch = "##{channel.gsub('#', '')}"
          Channel(ch).part
          m.reply "#{ch} parted!" unless ch == m.channel
        end
      end

      def show_status(m)
        @bot.channels.each.with_index(1) do |channel, i|
          number = ::Octospy.channel(channel).repos.count
          m.reply "#{"%02d" % i} #{channel}: #{number} repo"
        end
      end

      def show_commands(m)
        # @matchers.each.with_index(1) do |matcher, i|
          # m.reply "#{"%02d" % i} #{matcher}"
        # end
      end

      def join_on_invite(m)
        Channel(m.channel).join
      end
    end
  end
end
