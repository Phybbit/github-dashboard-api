class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session


  attr_reader :client
  attr_reader :redis
  before_action :setup

  def setup
    # Until the end of the transition period: Feb 24, 2015
    Octokit.default_media_type="application/vnd.github.moondragon+json"
    @client = Rails.configuration.octokit.new(access_token: current_user.github_token)
    @redis = Redis.current
  end

  def repo_list
    return ["okoriko/github-api-test"] if Rails.env.test?
    [
      "okoriko/github-api-test"
    ]
  end

  def store_pr_data_in_cache(data)
    data.each {|k,v| @redis.set cache_key(k), v.to_json}
  end

  def cache_key(key)
    "#{current_user.id}:#{self.class.to_s.underscore}:#{key}"
  end

end
