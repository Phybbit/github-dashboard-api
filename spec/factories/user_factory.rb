FactoryGirl.define do
  factory :user do
    nickname "okoriko"
    github_token "faketoken"
    password "123412341234"
    uid "1234123412341234"
    provider "github"
  end
end
