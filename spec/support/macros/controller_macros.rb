module ControllerMacros

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
      auth_headers = user.create_new_auth_token
      request.headers.merge!(auth_headers)
    end
  end

end
