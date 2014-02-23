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
          link: @event.payload.issue.html_url
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
          link: @event.payload.comment.html_url
        }
      end
    end
  end
end
