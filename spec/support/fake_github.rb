require 'sinatra/base'

# Base define basic answers that should not matters for the tests
class FakeGitHub < Sinatra::Base

  # curl -H "Authorization: token ACCESS_TOKEN" https://api.github.com/repos/okoriko/github-api-test/pulls
  get '/repos/:organization/:project/pulls' do
    json_response 200, 'pulls.json'
  end

  # curl -H "Authorization: token ACCESS_TOKEN" https://api.github.com/repos/okoriko/github-api-test/issues/1/comments
  get '/repos/:organization/:project/issues/:number/comments' do
    json_response 200, 'pull_request_comments_upvote_once.json'
  end

  # curl -H "Authorization: token ACCESS_TOKEN" https://api.github.com/repos/okoriko/github-api-test/issues/1
  get '/repos/:organization/:project/issues/:number' do
    json_response 200, 'pr_issue.json'
  end

  # curl -H "Authorization: token ACCESS_TOKEN" https://api.github.com/user
  get '/user' do
    json_response 200, 'user.json'
  end

  # curl -H "Authorization: token ACCESS_TOKEN" https://api.github.com/user/repos
  get '/user/repos' do
    json_response 200, 'user_repos.json'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/../fixtures/fake_github/' + file_name, 'rb').read
  end

end



class FakeGitHubUpvoteOnce < FakeGitHub
  # curl -H "Authorization: token ACCESS_TOKEN" https://api.github.com/repos/okoriko/github-api-test/issues/1/comments
  get '/repos/:organization/:project/issues/:number/comments' do
    json_response 200, 'pull_request_comments_upvote_once.json'
  end
end

class FakeGitHubUpvoteOnceOriginalAuthor < FakeGitHub
  # curl -H "Authorization: token ACCESS_TOKEN" https://api.github.com/repos/okoriko/github-api-test/issues/1/comments
  get '/repos/:organization/:project/issues/:number/comments' do
    json_response 200, 'pull_request_comments_upvote_once_original_author.json'
  end
end

class FakeGitHubNoUpvote < FakeGitHub
  # curl -H "Authorization: token ACCESS_TOKEN" https://api.github.com/repos/okoriko/github-api-test/issues/2/comments
  get '/repos/:organization/:project/issues/:number/comments' do
    json_response 200, 'pull_request_comments_no_upvote.json'
  end
end

class FakeGitHubUpvoteTwice < FakeGitHub
  # curl -H "Authorization: token ACCESS_TOKEN" https://api.github.com/repos/okoriko/github-api-test/issues/2/comments
  get '/repos/:organization/:project/issues/:number/comments' do
    json_response 200, 'pull_request_comments_upvote_twice.json'
  end
end

class FakeGitHubUpvoteTwiceSameAuthor < FakeGitHub
  # curl -H "Authorization: token ACCESS_TOKEN" https://api.github.com/repos/okoriko/github-api-test/issues/2/comments
  get '/repos/:organization/:project/issues/:number/comments' do
    json_response 200, 'pull_request_comments_upvote_twice_same_author.json'
  end
end

class FakeGitHubPullRequestBlocking < FakeGitHub
  # curl -H "Authorization: token ACCESS_TOKEN" https://api.github.com/repos/okoriko/github-api-test/issues/2/comments
  get '/repos/:organization/:project/issues/:number' do
    json_response 200, 'pr_issue_blocking.json'
  end
end
