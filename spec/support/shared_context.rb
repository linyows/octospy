shared_context :parser_params do
  let(:client) { double Octokit::Client }
  let(:parser) { described_class.new client }
  let(:event_name) { 'issue_comment_event' }
  let(:parsing_method) { :"parse_#{event_name}" }
  let(:file) { "#{event_name}.json" }
  let(:event) { Hashie::Mash.new.deep_merge(decode file) }

  let(:default_params) do
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

  let(:parsed_params) do
    {
      status: 'commented on issue #582',
      title: 'Remove `engines` from package.json.',
      body: [
        <<-BODY.pretty_heredoc
          Has is ever done anything? It still has a purpose though;
          To warn users that they're using antdated version.
        BODY
      ],
      link: 'https://github.com/bower/bower/issues/582#issuecomment-20416296'
    }
  end

  let(:merged_params) do
    default_params.merge(parsed_params).merge(
      nick: 'sindresorhus',
      repository: 'bower/bower'
    )
  end

  let(:built_params) do
    [
      {
        nick: merged_params[:nick],
        type: :notice,
        message: <<-MSG.pretty_heredoc
          (bower/bower) \u0002sindresorhus\u000F \u000308commented on issue #582\u000F
          Remove `engines` from package.json. - \u000302http://git.io/A0ARbg\u000F
        MSG
      },
      {
        nick: merged_params[:nick],
        type: :private,
        message: parsed_params[:body]
      }
    ]
  end
end
