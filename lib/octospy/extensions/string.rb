require 'string-irc'
require 'octospy/url'

module Octospy
  module Extensions
    module String
      def underscore
        self.gsub('::', '/').
          gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end

      def split_by_linefeed_except_blankline
        self.split(/\r\n|\n/).map { |v| v unless v.eql? '' }.compact
      end
      alias_method :split_lfbl, :split_by_linefeed_except_blankline

      def compact
        self.gsub(/\s+/, ' ').strip
      end

      def colorize_for_irc
        StringIrc.new(self)
      end

      def shorten_url
        Octospy::Url.shorten self
      end
      alias_method :shorten, :shorten_url
    end
  end
end

::String.__send__ :include, Octospy::Extensions::String
