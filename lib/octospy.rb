require 'awesome_print'
require 'cinch'
require 'octokit'
require 'dotenv'

require 'cinch/plugins/management'
require 'cinch/plugins/octospy'
require 'octospy/configurable'
require 'octospy/recordable'
require 'octospy/parser'
require 'octospy/worker'
require 'octospy/octokit/client'

module Octospy
  class << self
    include Octospy::Configurable

    def parse(event)
      Octospy::Parser.new(event).parse
    end

    def worker(repositories, &block)
      Octospy::Worker.new(repositories, &block)
    end

    def irc_bot
      Octokit.configure do |c|
        c.api_endpoint = Octospy.github_api_endpoint if Octospy.github_api_endpoint
        c.web_endpoint = Octospy.github_web_endpoint if Octospy.github_web_endpoint
        c.login        = Octospy.github_login
        c.access_token = Octospy.github_token
      end

      Cinch::Bot.new do
        configure do |c|
          c.server          = Octospy.server
          c.nick            = Octospy.nick
          c.channels        = Octospy.channels
          c.port            = Octospy.port if Octospy.port
          c.password        = Octospy.password if Octospy.password
          c.ssl.use         = Octospy.ssl if Octospy.ssl
          c.plugins.plugins = [
            Cinch::Plugins::Management,
            Cinch::Plugins::Octospy
          ]
        end
      end
    end

    def run
      self.irc_bot.start
    end
  end

  Dotenv.load ENV['DOTENV'] || '.env'
  Octospy.setup
end
