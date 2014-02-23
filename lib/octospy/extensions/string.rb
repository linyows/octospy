require 'string-irc'
require 'octospy/shortener'

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

      def colorize_for_irc
        StringIrc.new(self)
      end

      def shorten_url
        case
        when self =~ /https?:\/\/(\w+\.)?github\.com/
          Octospy::Shortener.shorten_by_github self
        when self =~ /https?:\/\/.+/
          Octospy::Shortener.shorten_by_google self
        else
          self
        end
      end
      alias_method :shorten, :shorten_url
    end
  end
end

::String.__send__ :include, Octospy::Extensions::String
