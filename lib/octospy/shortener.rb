require 'faraday'
require 'faraday_middleware'

module Octospy
  module Shortener
    class << self
      def github_shortener_endpoint
        'http://git.io'
      end

      def shorten_by_github(url)
        conn = Faraday.new(url: self.github_shortener_endpoint) do |f|
          f.request  :url_encoded
          f.adapter  Faraday.default_adapter
        end

        res = conn.post '/', { url: url }
        res.headers && res.headers.key?('location') ? res.headers['location'] : url
      rescue
        url
      end

      def google_shortener_endpoint
        'https://www.googleapis.com'
      end

      def shorten_by_google(url)
        conn = Faraday.new(url: self.google_shortener_endpoint) do |f|
          f.response :mashify
          f.response :json
          f.request  :url_encoded
          f.request  :json
          f.adapter  Faraday.default_adapter
        end

        res = conn.post do |req|
          req.url '/urlshortener/v1/url'
          req.headers['Content-Type'] = 'application/json'
          req.body = "{ \"longUrl\": \"#{url}\" }"
        end

        res.body && res.body.respond_to?(:id) ? res.body.id : url
      rescue
        url
      end
    end
  end
end
