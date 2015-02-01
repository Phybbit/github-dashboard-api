class SummaryController < PullRequestsController
  before_filter :authenticate_user!


  def index
    summary = retrieve_summary

    render json: summary
  end

  def retrieve_summary
    prs = []
    reviewed = []
    me = current_user.nickname

    repos = client.repos
    repos.each do |repo|
      repo_name = repo[:full_name]
      next unless repo_list.include? repo_name

      pull_requests_data = retrieve_pull_requests(repo_name, :all)
      pull_requests_data.each do |pr|
        is_within_24h = pr[:created_at] > Time.now - 1.day
        next unless is_within_24h

        prs << pr if pr[:user][:login] == me
        reviewed << pr if pr[:upvoters].any? {|voter| voter[:login] == me}
      end
    end

    prs.sort!{|pr1, pr2| pr2[:created_at].to_i - pr1[:created_at].to_i}
    reviewed.sort!{|pr1, pr2| pr2[:created_at].to_i - pr1[:created_at].to_i}

    {
      pr_made: prs,
      reviewed: reviewed
    }
  end


end
