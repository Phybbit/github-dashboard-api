require 'rails_helper'

RSpec.describe PullRequestsController, :type => :controller do
  login_user

  let (:controller) { PullRequestsController.new }

  before do
    Redis.current.flushdb

    controller.stub(:current_user).and_return(User.first)
    controller.setup
  end

  context "cache" do
    let (:data) { {"test" => 1} }

    it "store data in cache" do
      controller.store_pr_data_in_cache({no_review: data})
      expect(controller.retrieve_pr_data_from_cache[:no_review]).to eq data
    end

    it "stores in the cache after the first request" do
      stub_request(:any, /api.github.com/).to_rack(FakeGitHubUpvoteOnce)
      expect(controller.retrieve_pr_data_from_cache[:no_review]).to be nil
      get :index
      expect(controller.retrieve_pr_data_from_cache[:no_review]).not_to be nil
    end

    it "refresh will hit the api again even with the cache set" do
      stub_request(:any, /api.github.com/).to_rack(FakeGitHubUpvoteOnce)
      get :index # fill the cache once
      WebMock.reset! # reset both stubs and request history

      stub_request(:any, /api.github.com/).to_rack(FakeGitHubUpvoteOnce)
      get :refresh
      expect(a_request(:any, /api.github.com/)).to have_been_made.at_least_once
    end
  end

  context "one upvote" do
    it "in review means upvote >= 1" do
      stub_request(:any, /api.github.com/).to_rack(FakeGitHubUpvoteOnce)
      get :index
      expect(JSON.parse(response.body)["in_review"].count).to eq(1)
    end

    it "upvote from PR original author does not count" do
      stub_request(:any, /api.github.com/).to_rack(FakeGitHubUpvoteOnceOriginalAuthor)
      get :index
      expect(JSON.parse(response.body)["no_review"].count).to eq(1)
    end
  end

  context "no upvote" do
    it "no_review means upvote == 0" do
      stub_request(:any, /api.github.com/).to_rack(FakeGitHubNoUpvote)
      get :index
      expect(JSON.parse(response.body)["no_review"].count).to eq(1)
    end
  end

  context "two upvote" do
    it "ready to merge means upvote >= 2" do
      stub_request(:any, /api.github.com/).to_rack(FakeGitHubUpvoteTwice)
      get :index
      expect(JSON.parse(response.body)["merge_ready"].count).to eq(1)
    end

    it "2 upvotes from same author do not count" do
      stub_request(:any, /api.github.com/).to_rack(FakeGitHubUpvoteTwiceSameAuthor)
      get :index
      expect(JSON.parse(response.body)["in_review"].count).to eq(1)
    end
  end

  context "labels" do
    it "categorizes blocking label" do
      stub_request(:any, /api.github.com/).to_rack(FakeGitHubPullRequestBlocking)
      get :index
      expect(JSON.parse(response.body)["blocking"].count).to eq(1)
    end
  end
end
