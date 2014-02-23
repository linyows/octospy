module Octospy
  class Parser
    module PullRequest
      def parse_pull_request_event
        {
          status: "#{@event.payload.action} pull request ##{@event.payload.number}",
          title: @event.payload.pull_request.title,
          body: "#{@event.payload.pull_request.body}".split_lfbl,
          link: @event.payload.pull_request.html_url
        }
      end

      def parse_pull_request_review_comment_event
        if @event.payload.comment.pull_request_url
          url = @event.payload.comment.pull_request_url
          pull_id = url.match(/\/pulls\/([0-9]+)/)[1]
          pull = Octokit.pull(@event.repo.name, pull_id)
          title = "#{pull.title}: #{@event.payload.comment.path}"
        else
          title = @event.payload.comment.path
        end

        {
          status: "commented on pull request",
          title: title,
          body: "#{@event.payload.comment.body}".split_lfbl,
          link: @event.payload.comment._links.html.href
        }
      end
    end
  end
end
