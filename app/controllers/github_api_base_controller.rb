class GithubApiBaseController < ApplicationController

  attr_reader :client
  before_action :setup_client

  def setup_client
    # Until the end of the transition period: Feb 24, 2015
    Octokit.default_media_type="application/vnd.github.moondragon+json"
    @client = Rails.configuration.octokit.new(access_token: current_user.github_token)
  end

  def repo_list
    return ["okoriko/github-api-test"] if Rails.env.test?
    [
      "okoriko/github-api-test"
    ]
  end
  
end
