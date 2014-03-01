module Octospy
  class Parser
    module User
      def parse_watch_event
        # This is not watch event, this is star event
        # {
        #   status: "#{@event.payload.action} to watch",
        #   title: nil,
        #   link: "#{Octokit.web_endpoint}#{@event.repo.name}/watchers",
        #   repository: @event.repo.name
        # }
        {
          status: 'starred',
          title: nil,
          link: "#{Octokit.web_endpoint}#{@event.repo.name}/stargazers",
          repository: @event.repo.name
        }
      end

      def parse_follow_event
        user = @event.payload.target

        title = user.login
        title = "#{title} (#{user.name})" if user.name && user.name != ''
        profile = ["#{'repos'.colorize_for_irc.silver}: #{user.public_repos}"]
        profile << "#{'followers'.colorize_for_irc.silver}: #{user.followers}"
        profile << "#{'following'.colorize_for_irc.silver}: #{user.following}"
        profile << "#{'location'.colorize_for_irc.silver}: #{user.location && user.location != '' ? user.location : '-'}"
        profile << "#{'company'.colorize_for_irc.silver}: #{user.company && user.company != '' ? user.company : '-'}"
        profile << "#{'bio'.colorize_for_irc.silver}: #{user.bio && user.bio != '' ? user.bio : '-'}"
        profile << "#{'blog'.colorize_for_irc.silver}: #{user.blog && user.blog != '' ? user.blog : '-'}"

        {
          status: "followed",
          title: title,
          body: profile.join(', '),
          link: "#{Octokit.web_endpoint}#{user.login}",
          repository: nil,
          notice: true
        }
      end
    end
  end
end
