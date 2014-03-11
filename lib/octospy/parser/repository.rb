module Octospy
  class Parser
    module Repository
      def parse_commit_comment_event
        commit_url = "#{Octokit.web_endpoint}#{@event.repo.name}/commit/#{@event.payload.comment.commit_id}"

        {
          status: "commented on commit",
          title: "#{@event.payload.comment.path}",
          body: "#{@event.payload.comment.body}".split_lfbl,
          link: "#{commit_url}#commitcomment-#{@event.payload.comment.id}"
        }
      end

      def parse_push_event
        body = []
        branch = @event.payload.ref.gsub('refs/heads/', '')

        @event.payload.commits.each do |commit|
          verbose_commit = Octokit.commit(@event.repo.name, commit.sha)
          name = "#{verbose_commit.author ? verbose_commit.author.login : commit.author.name}"
          link = "#{Octokit.web_endpoint}#{@event.repo.name}/commit/#{commit.sha}"
          line = "#{name.to_s.colorize_for_irc.silver}: #{commit.message}"
          line << " - #{link.shorten.to_s.colorize_for_irc.blue}"
          body = body + "#{line}".split_lfbl
        end

        {
          status: "pushed to #{branch}",
          body: body,
          link: "#{Octokit.web_endpoint}#{@event.repo.name}/tree/#{branch}",
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
          status: "forked to #{forkee_name}",
          title: "#{forkee_lang}: #{@event.payload.forkee.description}",
          link: "#{Octokit.web_endpoint}#{@event.payload.forkee.full_name}"
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
