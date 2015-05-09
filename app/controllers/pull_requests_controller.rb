class PullRequestsController < GithubApiBaseController
  before_filter :authenticate_user!

  def index
    pr_data = retrieve_pr_data
    render json: pr_data
  end

  def refresh
    pr_data = refresh_pr_data
    render json: pr_data
  end

  def retrieve_pr_data
    updated_at = @redis.get cache_key(:updated_at)
    return retrieve_pr_data_from_cache if updated_at.present?

    refresh_pr_data
  end

  def refresh_pr_data
    pr_data = retrieve_pr_data_from_api
    store_pr_data_in_cache(pr_data)
    pr_data
  end


  def retrieve_pr_data_from_cache
    pr_data = {}
    keys = [:no_review, :in_review, :merge_ready, :recently_merged, :blocking, :updated_at]
    keys.each do |key|
      value = @redis.get(cache_key(key))
      pr_data[key] = JSON.parse(value, quirks_mode: true) if value.present?
    end
    pr_data
  end


  def retrieve_pr_data_from_api
    no_review = []
    in_review = []
    merge_ready = []
    blocking = []
    recently_merged = []

    repos = client.repos
    repos.each do |repo|
      repo_name = repo[:full_name]
      next unless repo_list.include? repo_name

      pull_requests_data = retrieve_pull_requests(repo_name, :open)
      pull_requests_data.each do |pr|
        upvotes = pr[:upvoters].count
        if upvotes == 0
          no_review << pr
        elsif upvotes == 1
          in_review << pr
        elsif upvotes == 2
          merge_ready << pr
        end

        if has_blocking_label(pr[:labels])
          blocking << pr
        end
      end

      options = {sort: "created", direction: "desc", per_page: 5}
      recently_merged += retrieve_pull_requests(repo_name, :closed, options)
    end

    # Sort by more recent first (reverse order or updated_at)
    recently_merged = recently_merged.sort{|pr1, pr2| pr2[:merged_at].to_i - pr1[:merged_at].to_i}.first(5)
    {
      no_review: no_review,
      in_review: in_review,
      merge_ready: merge_ready,
      recently_merged: recently_merged,
      blocking: blocking,
      updated_at: DateTime.now
    }
  end


  private

  def retrieve_pull_requests(repo, state, options = {})
    data = []
    params = {
      state: state.to_s
    }
    params.merge!(options) if options.present?
    pull_requests = client.pull_requests(repo, options)
    pull_requests.each do |pull_request|
      pr = {
        repo: repo,
        number: pull_request[:number],
        url: pull_request[:html_url],
        title: pull_request[:title],
        user: pull_request[:user].to_hash,
        created_at: pull_request[:created_at],
        updated_at: pull_request[:updated_at],
        upvoters: retrieve_upvoters(repo, pull_request),
        labels: retrieve_labels(repo, pull_request),
      }
      data << pr
    end
    data
  end


  def has_blocking_label(labels)
    labels.find{|label| label[:name] =~ /block/ }.present?
  end

  def retrieve_labels(repo, pull_request)
    issue = client.issue(repo, pull_request[:number])
    issue[:labels].map {|label| label.to_hash }
  end

  def retrieve_upvoters(repo, pull_request)
    upvoters = []
    author = pull_request[:user].to_hash
    comments = client.issue_comments(repo, pull_request[:number])

    comments.each do |comment|
      user = comment[:user].to_hash
      if comment[:body] =~ /:\+1:/
        upvoters << user if is_new_upvote?(upvoters, author, user)
      end
    end

    upvoters
  end

  def is_new_upvote?(upvoters, author, user)
    return false if upvoters.include? user
    return false if author == user
    true
  end

end
