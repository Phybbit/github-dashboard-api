require 'rails_helper'

RSpec.describe SummaryController, :type => :controller do
  login_user

  let (:controller) { SummaryController.new }
  let (:user) { User.first }

  let (:pr_2days_ago) {
    {
      number: 1,
      user: {
        login: "okoriko"
      },
      created_at: DateTime.now - 2.days
    }
  }
  let (:pr_almost_1day_ago) {
    {
      number: 2,
      user: {
        login: "okoriko"
      },
      created_at: DateTime.now - 1.day + 1.minute
    }
  }
  let (:pr_now) {
    {
      number: 3,
      user: {
        login: "okoriko"
      },
      created_at: DateTime.now
    }
  }
  let (:pr_now_but_not_mine) {
    {
      number: 4,
      user: {
        login: "not mine"
      },
      created_at: DateTime.now
    }
  }


  before do
    Redis.current.flushdb

    controller.stub(:current_user).and_return(user)
    controller.setup

    stub_request(:any, /repos$/).to_rack(FakeGitHub)
    stub_request(:get, /pulls/).to_return(body: [
      pr_2days_ago,
      pr_almost_1day_ago,
      pr_now,
      pr_now_but_not_mine
    ])
  end


  context "PR made yesterday" do
    before do
      stub_request(:any, /issue/).to_rack(FakeGitHub)
    end

    it "lists my last 24hours PR" do
      get :index
      result = JSON.parse(response.body)
      expect(result['pr_made'].count).to eq 2
    end

    it "orders by latest" do
      get :index
      result = JSON.parse(response.body)
      t0 = Time.parse(result['pr_made'][0]['created_at'])
      t1 = Time.parse(result['pr_made'][1]['created_at'])
      expect(t0).to be > t1
    end

  end

  context "count reviews" do

    it "retrieves the reviews I made" do
      user.nickname = 'okoriko1'
      user.save!

      stub_request(:any, /issue/).to_rack(FakeGitHubUpvoteOnce)
      get :index
      result = JSON.parse(response.body)
      expect(result['reviewed'].count).to eq 3
    end

  end

end
