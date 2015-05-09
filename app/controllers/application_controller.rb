class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session


  attr_reader :redis
  before_action :setup_redis

  def setup_redis
    @redis = Redis.current
  end

  def store_pr_data_in_cache(data)
    data.each {|k,v| @redis.set cache_key(k), v.to_json}
  end

  def cache_key(key)
    "#{current_user.id}:#{self.class.to_s.underscore}:#{key}"
  end

end
