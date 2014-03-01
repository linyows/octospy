require 'sawyer'

module Octospy
  module Url
    class << self
      def shorten(url)
        case
        when url =~ /https?:\/\/(\w+\.)?github\.com/
          self.shorten_by_github url
        when url =~ /https?:\/\/.+/
          self.shorten_by_google url
        else
          url
        end
      end

      def github_shortener_endpoint
        'http://git.io/'
      end

      def shorten_by_github(url)
        agent = Sawyer::Agent.new(self.github_shortener_endpoint)
        response = agent.call(:post, '', "url=#{url}")
        response.headers[:location]
      rescue => e
        puts e.message
        url
      end

      def google_shortener_endpoint
        'https://www.googleapis.com/urlshortener/v1/'
      end

      def shorten_by_google(url)
        agent = Sawyer::Agent.new(self.google_shortener_endpoint) do |http|
          http.headers['Content-Type'] = 'application/json'
        end
        response = agent.call(:post, 'url', longUrl: url)
        response.data.attrs[:id]
      rescue => e
        puts e.message
        url
      end
    end
  end
end
