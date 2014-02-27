module Octospy
  class Parser
    module Issue
      def parse_issues_event
        body = "#{@event.payload.issue.body}".split_lfbl

        if @event.payload.issue.assignee
          body << "assignee: #{@event.payload.issue.assignee.login}"
        end

        if @event.payload.issue.milestone
          milestone_title = @event.payload.issue.milestone.title
          milestone_state = @event.payload.issue.milestone.state
          body << "milestone: #{milestone_title}[#{milestone_state}]"
        end

        {
          status: "#{@event.payload.action} issue ##{@event.payload.issue.number}",
          title: @event.payload.issue.title,
          body: body,
          link: "#{Octokit.web_endpoint}#{@event.repo.name}/issues/#{@event.payload.issue.number}"
        }
      end

      def parse_issue_comment_event
        if @event.payload.action == 'created'
          status = "commented on issue ##{@event.payload.issue.number}"
          title = @event.payload.issue.title
        else
          status = "#{@event.payload.action} issue comment"
          title = ''
        end

        {
          status: status,
          title: title,
          body: "#{@event.payload.comment.body}".split_lfbl,
          link: "#{Octokit.web_endpoint}#{@event.repo.name}/issues/#{@event.payload.issue.number}#issuecomment-#{@event.payload.comment.id}"
        }
      end
    end
  end
end
