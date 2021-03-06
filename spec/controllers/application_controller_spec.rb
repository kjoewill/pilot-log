require 'spec_helper'
require 'pry'

describe ApplicationController do

  describe "Homepage" do
    it 'loads the homepage' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to Pilot Log Book")
    end
  end


  describe "Signup Page" do

    it 'loads the signup page' do
      get '/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs user to user home page' do
      params = {
        :username => "K2",
        :password => "K2"
      }
      post '/signup', params
      follow_redirect!
      expect(last_response.body).to include("Home Page for:")
    end

    it 'does not let a user sign up without a username' do
      params = {
        :username => "",
        :password => "rainbows"
      }
      post '/signup', params
      follow_redirect!
      expect(last_response.body).to include('Sign Up')
    end

    it 'does not let a user sign up without a password' do
      params = {
        :username => "skittles123",
        :password => ""
      }
      post '/signup', params
      follow_redirect!
      expect(last_response.body).to include('Sign Up')
    end

    it 'creates a new user and logs them in on valid submission and does not let a logged in user view the signup page' do
      params = {
        :username => "K2",
        :password => "K2"
      }
      post '/signup', params
      follow_redirect!
      expect(last_response.body).to include('Home Page for:')
      get '/signup'
      follow_redirect!
      expect(last_response.body).to include('Home Page for:')
    end
  end

  describe "login" do
    it 'loads the login page' do
      get '/login'
      expect(last_response.status).to eq(200)
    end

    it 'loads the user home page after login' do
      user = User.create(:username => "becky567", :password => "kittens")
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      follow_redirect!
      expect(last_response.body).to include("Home Page for: becky567")
    end

    it 'does not let user view login page if already logged in' do
      user = User.create(:username => "becky567", :password => "kittens")
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      get '/login'
      follow_redirect!
      expect(last_response.body).to include("Home Page for: becky567")
    end
  end


  describe "logout" do
    it "lets a user logout if they are already logged in" do
      user = User.create(:username => "becky567", :password => "kittens")

      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      get '/logout'
      follow_redirect!
      expect(last_response.body).to include("Welcome to Pilot Log Book")
    end

    it 'does not let a user logout if not logged in' do
      get '/logout'
      follow_redirect!
      expect(last_response.body).to include("Welcome to Pilot Log Book")
    end

    it 'does load user index if user is logged in' do
      user = User.create(:username => "becky567", :password => "kittens")

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      get '/users/current_user'
      expect(page.status_code).to eq(200)
      expect(page.body).to include("Home Page for:")
    end
  end

  describe 'user show page' do
    it 'shows all a single users index page' do
      k2 = User.create(username: "K2", password: "K2")

      k2.flight_records << FlightRecord.create(
        date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "K2's flight", num_landings: 1, duration: 60)

      k2.flight_records << FlightRecord.create(
        date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

      visit '/login'

      fill_in(:username, :with => "K2")
      fill_in(:password, :with => "K2")
      click_button 'submit'

      get "/users/current_user"

      expect(page.body).to include("K2")
      expect(page.body).to include(Date.today.to_s)

    end
  end



  describe 'user show action' do
    context 'logged in' do
      it 'lets a user view their home page if logged in' do
        k2 = User.create(username: "K2", password: "K2")
        k2.flight_records << FlightRecord.create(
          date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "K2's flight", num_landings: 1, duration: 60)
        k2.flight_records << FlightRecord.create(
          date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

        visit '/login'

        fill_in(:username, :with => "K2")
        fill_in(:password, :with => "K2")
        click_button 'submit'

        expect(page.body).to include("K2")
        expect(page.body).to include(Date.today.to_s)

      end
    end

    context 'logged out' do
      it 'does not let a user view their home page when not logged in' do
        get "/users/current_user"
        follow_redirect!
        expect(last_response.body).to include("Welcome to Pilot Log Book")
      end
    end
  end




  describe 'new action' do
    context 'logged in' do

      it 'lets user create a FR if they are logged in' do
        user = User.create(:username => "becky567", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/flight_records/new'
        fill_in(:date, :with => Date.today.to_s)
        fill_in(:aircraft_type, :with => "SR20")
        fill_in(:from, :with => "KFLY")
        fill_in(:to, :with => "KCOS")
        fill_in(:remarks, :with => "Test suite remark")
        fill_in(:num_landings, :with => 1)
        fill_in(:duration, :with => 20)


        click_button 'submit'

        user = User.find_by(:id=> user.id)
        fr = FlightRecord.find_by(:remarks => "Test suite remark")
        expect(fr).to be_instance_of(FlightRecord)
        expect(fr.user_id).to eq(user.id)

        expect(page.status_code).to eq(200)

      end


      it 'does not let a user create a FR with a blank from: field' do
        user = User.create(:username => "becky567", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/tweets/new'

        visit '/flight_records/new'
        fill_in(:date, :with => Date.today.to_s)
        fill_in(:aircraft_type, :with => "SR20")
        fill_in(:from, :with => "")
        fill_in(:to, :with => "KCOS")
        fill_in(:remarks, :with => "I have no from: field")
        fill_in(:num_landings, :with => 1)
        fill_in(:duration, :with => 20)

        click_button 'submit'

        expect(FlightRecord.find_by(:remarks => "I have no from: field")).to eq(nil)
        expect(page.current_path).to eq("/flight_records/new")
      end
    end

    context 'logged out' do
      it 'does not let user view new FR form if not logged in' do
        get '/flight_records/new'
        expect(last_response.location).to include("/login")
      end
    end
  end

=begin

  describe 'show action' do
    context 'logged in' do
      it 'displays a single tweet' do

        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "i am a boss at tweeting", :user_id => user.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/tweets/#{tweet.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Delete Tweet")
        expect(page.body).to include(tweet.content)
        expect(page.body).to include("Edit Tweet")
      end
    end

    context 'logged out' do
      it 'does not let a user view a tweet' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "i am a boss at tweeting", :user_id => user.id)
        get "/tweets/#{tweet.id}"
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'edit action' do
    context "logged in" do
      it 'lets a user view tweet edit form if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "tweeting!", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/tweets/1/edit'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(tweet.content)
      end

      it 'does not let a user edit a tweet they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet1 = Tweet.create(:content => "tweeting!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        tweet2 = Tweet.create(:content => "look at this tweet", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/tweets/#{tweet2.id}/edit"
        expect(page.current_path).to include('/tweets')
      end

      it 'lets a user edit their own tweet if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/tweets/1/edit'

        fill_in(:content, :with => "i love tweeting")

        click_button 'submit'
        expect(Tweet.find_by(:content => "i love tweeting")).to be_instance_of(Tweet)
        expect(Tweet.find_by(:content => "tweeting!")).to eq(nil)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user edit a text with blank content' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/tweets/1/edit'

        fill_in(:content, :with => "")

        click_button 'submit'
        expect(Tweet.find_by(:content => "i love tweeting")).to be(nil)
        expect(page.current_path).to eq("/tweets/1/edit")
      end
    end

    context "logged out" do
      it 'does not load -- instead redirects to login' do
        get '/tweets/1/edit'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'delete action' do
    context "logged in" do
      it 'lets a user delete their own tweet if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit 'tweets/1'
        click_button "Delete Tweet"
        expect(page.status_code).to eq(200)
        expect(Tweet.find_by(:content => "tweeting!")).to eq(nil)
      end

      it 'does not let a user delete a tweet they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet1 = Tweet.create(:content => "tweeting!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        tweet2 = Tweet.create(:content => "look at this tweet", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "tweets/#{tweet2.id}"
        click_button "Delete Tweet"
        expect(page.status_code).to eq(200)
        expect(Tweet.find_by(:content => "look at this tweet")).to be_instance_of(Tweet)
        expect(page.current_path).to include('/tweets')
      end
    end

    context "logged out" do
      it 'does not load let user delete a tweet if not logged in' do
        tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
        visit '/tweets/1'
        expect(page.current_path).to eq("/login")
      end
    end
  end

=end
end
