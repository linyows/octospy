require 'octospy/extensions/string'
require 'octospy/parser/user'
require 'octospy/parser/organization'
require 'octospy/parser/repository'
require 'octospy/parser/issue'
require 'octospy/parser/pull_request'
require 'octospy/parser/wiki'
require 'octospy/parser/download'
require 'octospy/parser/gist'
require 'octospy/parser/release'

module Octospy
  class Parser
    include User
    include Organization
    include Repository
    include Issue
    include PullRequest
    include Wiki
    include Download
    include Gist
    include Release

    def initialize(event)
      @event = event
    end

    def default_params
      {
        notice_body: false,
        none_repository: false,
        nick: '',
        repository: '',
        status: '',
        link: '',
        title: '',
        body: []
      }
    end

    def parse
      hash = default_params.merge(
        nick: @event.actor.login,
        repository: @event.repo.name
      )
      hash.merge! self.send(parsing_method)
      build(hash)
    end

    def build(hash)
      header = "#{hash[:nick].colorize_for_irc.bold} #{colorize_to hash[:status]}"

      if hash[:repository] && !hash[:repository].empty?
        header = "(#{hash[:repository]}) #{header}"
      end

      if hash[:title] && !hash[:title].empty?
        header = "#{header} #{hash[:title]}"
      end

      if hash[:link] && !hash[:link].empty?
        header = "#{header} - #{hash[:link].shorten.colorize_for_irc.blue}"
      end

      body = if hash[:body].length > 20
          body_footer = hash[:body][-3..-1]
          body = hash[:body][0...15]
          body << '-----8<----- c u t -----8<-----'
          body + body_footer
        else
          hash[:body]
        end

      [
        {
          nick: hash[:nick],
          type: :notice,
          message: header
        },
        {
          nick: hash[:nick],
          type: hash[:notice_body] ? :notice : :private,
          message: body
        }
      ]
    end

    def parsing_method
      "Parse#{@event.type}".underscore.to_sym
    end

    def color_table
      {
        default: :aqua,
        created: :pink,
        commented: :yellow,
        pushed: :lime,
        forked: :orange,
        closed: :brown,
        deleted: :red,
        edited: :green,
        published: :blue,
        started: :rainbow,
        followed: :seven_eleven,
        saved: :cyan
      }
    end

    def behavior_color(string)
      color_table.each { |word, color|
        return color if string.include? "#{word}"
      }
      color_table[:default]
    end

    def colorize_to(string)
      string.colorize_for_irc.send(behavior_color string).to_s
    end
  end
end
