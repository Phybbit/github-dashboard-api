class OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController

  def whitelisted_params
    {github_token: auth_hash["credentials"]["token"]}
  end

end
