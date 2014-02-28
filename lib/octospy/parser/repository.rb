module Octospy
  class Parser
    module Repository
      def parse_commit_comment_event
        {
          status: "commented on commit",
          title: "#{@event.payload.comment.path}",
          body: "#{@event.payload.comment.body}".split_lfbl,
          link: @event.payload.comment.html_url
        }
      end

      def parse_push_event
        body = []
        @event.payload.commits.each do |commit|
          verbose_commit = Octokit.commit(@event.repo.name, commit.sha)
          name = "#{verbose_commit.author ? verbose_commit.author.login : commit.author.name}"
          link = "#{Octokit.web_endpoint}#{@event.repo.name}/commit/#{commit.sha}"
          line = "#{name.colorize_for_irc.silver}: #{commit.message}"
          line << " - #{link.shorten.colorize_for_irc.blue}"
          body = body + "#{line}".split_lfbl
        end

        {
          status: "pushed to #{@event.payload.ref.gsub('refs/heads/', '')}",
          body: body,
          link: "#{Octokit.web_endpoint}#{@event.repo.name}",
          notice_body: true
        }
      end

      def parse_create_event
        if @event.payload.ref_type.eql? 'repository'
          title = @event.repo.name
          title = "#{title}: #{@event.payload.description}" if @event.payload.description
          {
            status: "created repository",
            title: title,
            link: "#{Octokit.web_endpoint}#{@event.repo.name}",
            repository: nil
          }
        else
          {
            status: "created #{@event.payload.ref_type}:#{@event.payload.ref}",
            title: @event.payload.description,
            link: "#{Octokit.web_endpoint}#{@event.repo.name}"
          }
        end
      end

      def parse_delete_event
        {
          status: "deleted #{@event.payload.ref_type}:#{@event.payload.ref}",
          link: "#{Octokit.web_endpoint}#{@event.repo.name}"
        }
      end

      def parse_fork_event
        forkee_name = @event.payload.forkee.full_name
        forkee_lang = @event.payload.forkee.language
        {
          status: "forked #{forkee_name} [#{forkee_lang}]",
          title: @event.payload.forkee.description,
          link: @event.payload.forkee.html_url
        }
      end

      def parse_public_event
        {
          status: "published #{@event.repo.name}",
          link: "#{Octokit.web_endpoint}#{@event.repo.name}"
        }
      end

      def parse_fork_apply_event
        {}
      end
    end
  end
end
