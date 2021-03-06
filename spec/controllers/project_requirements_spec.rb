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


  describe "Req #5 -  Sign up, sign in, sign out" do

    it 'loads the signup page' do
      get '/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs user to user index' do
      params = {
        :username => "Raptor",
        :password => "Raptor"
      }
      post '/signup', params
      follow_redirect!
      expect(last_response.body).to include("Home Page for: Raptor")
    end

    it 'does not let a user sign up without a username' do
      params = {
        :username => "",
        :password => "Raptor"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without a password' do
      params = {
        :username => "Raptor",
        :password => ""
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'creates a new user and logs them in on valid submission and does not let a logged in user view the signup page' do
      params = {
        :username => "Raptor",
        :password => "Raptor"
      }
      post '/signup', params
      get '/signup'
      follow_redirect!
      expect(last_response.body).to include('Home Page for: Raptor')
    end
  end

  describe "Req #5 - login" do
    it 'loads the login page' do
      get '/login'
      expect(last_response.status).to eq(200)
    end

    it 'loads the user index after login' do
      user = User.create(:username => "Raptor", :password => "Raptor")
      params = {
        :username => "Raptor",
        :password => "Raptor"
      }
      post '/login', params
      follow_redirect!
      expect(last_response.body).to include("Home Page for: Raptor")
    end

    it 'does not let user view login page if already logged in' do
      user = User.create(:username => "Raptor", :password => "Raptor")
      params = {
        :username => "Raptor",
        :password => "Raptor"
      }
      post '/login', params
      get '/login'
      follow_redirect!
      expect(last_response.body).to include("Home Page for: Raptor")
    end
  end

  describe "Req #5 - logout" do
    it "lets a user logout if they are already logged in" do
      user = User.create(:username => "Raptor", :password => "Raptor")

      params = {
        :username => "Raptor",
        :password => "Raptor"
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

    it 'does not load user home page if user not logged in' do
      get "/users/1"
      follow_redirect!
      expect(last_response.body).to include("Welcome to Pilot Log Book")
    end

    it 'does load user index if user is logged in' do
      user = User.create(:username => "Raptor", :password => "Raptor")

      visit '/login'

      fill_in(:username, :with => "Raptor")
      fill_in(:password, :with => "Raptor")
      click_button 'submit'
      get '/users/current_user'
      expect(page.status_code).to eq(200)
      expect(page.body).to include("Home Page for:")
    end
  end

  describe 'Req #6 - Validate uniqueness of user login attribute (username)' do
    it 'does not let a user sign up with a duplicate username' do
      user = User.create(:username => "Raptor", :password => "Raptor")

      params = {
        :username => "Raptor",
        :password => "Raptor"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end
  end



  describe 'Req #7 Logged in user CRUD against owned Flight Records' do

    context 'create' do
      it 'lets user create a FR' do
        user = User.create(:username => "Raptor", :password => "Raptor")

        visit '/login'

        fill_in(:username, :with => "Raptor")
        fill_in(:password, :with => "Raptor")
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
    end

    context 'read' do
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
        expect(page).to have_content(Date.today.to_s, count: 2)
        expect(page).to have_content("SR20", count: 2)

      end
    end

    context 'update' do
      it 'lets a user modify owned flight records' do
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

        first(:link, 'Details').click
        expect(page.body).to include("Flight Record Inspect Page")

        click_button 'Edit'
        expect(page.body).to include("Edit Flight Record")

        fill_in(:aircraft_type, :with => "Brand New Aircraft Type")
        click_button 'Update'
        expect(page.body).to include("Brand New Aircraft Type")
      end
    end

    context 'delete' do
      it 'lets a user delete owned flight records' do
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

        first(:link, 'Details').click
        expect(page.body).to include("Flight Record Inspect Page")

        click_button 'Delete'
        expect(page).to have_content(Date.today.to_s, count: 1)

      end
    end

  end

  describe 'Req #8 Logged in user cannot CRUD against others Flight Records' do

    context 'create' do
      it 'FRs only created in the context of a logged in user' do

      end
    end

    context 'read' do
      it 'wont let a user view other user home page' do

      k1 = User.create(username: "K1", password: "K1")
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
        expect(page).to have_content(Date.today.to_s, count: 2)
        expect(page).to have_content("SR20", count: 2)

        visit "/users/#{k1.id}"
        expect(page.body).to include("Welcome to Pilot Log Book")

      end
    end

    context 'update' do
      it 'only allows edits in context of a logged in user ' do

      end
    end

    context 'delete' do
      it 'only allows deletes in context of logged in user of owned flight records' do

      end
    end
  end

  describe 'Req #9 - Validate user input so bad data cannot be persisted to the database' do

    context 'empty fields' do

      it 'will not allow creation of a FR with an empty Aircraft type' do
        k2 = User.create(username: "K2", password: "K2")
        k2.flight_records << FlightRecord.create(
          date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "K2's flight", num_landings: 1, duration: 60)
        k2.flight_records << FlightRecord.create(
          date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

        visit '/login'

        fill_in(:username, :with => "K2")
        fill_in(:password, :with => "K2")
        click_button 'submit'

        visit '/flight_records/new'
        fill_in(:date, :with => Date.today.to_s)
        fill_in(:aircraft_type, :with => "")
        fill_in(:from, :with => "KFLY")
        fill_in(:to, :with => "KCOS")
        fill_in(:remarks, :with => "Test suite remark")
        fill_in(:num_landings, :with => 1)
        fill_in(:duration, :with => 20)


        click_button 'submit'

        expect(page.body).to include('Create a new Flight record')

      end

      it 'will not allow creation of a FR with an empty from: field' do
        k2 = User.create(username: "K2", password: "K2")
        k2.flight_records << FlightRecord.create(
          date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "K2's flight", num_landings: 1, duration: 60)
        k2.flight_records << FlightRecord.create(
          date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

        visit '/login'

        fill_in(:username, :with => "K2")
        fill_in(:password, :with => "K2")
        click_button 'submit'

        visit '/flight_records/new'
        fill_in(:date, :with => Date.today.to_s)
        fill_in(:aircraft_type, :with => "SR22")
        fill_in(:from, :with => "")
        fill_in(:to, :with => "KCOS")
        fill_in(:remarks, :with => "Test suite remark")
        fill_in(:num_landings, :with => 1)
        fill_in(:duration, :with => 20)


        click_button 'submit'

        expect(page.body).to include('Create a new Flight record')

      end

      it 'will not allow creation of a FR with a negative number of landing' do
        k2 = User.create(username: "K2", password: "K2")
        k2.flight_records << FlightRecord.create(
          date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "K2's flight", num_landings: 1, duration: 60)
        k2.flight_records << FlightRecord.create(
          date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

        visit '/login'

        fill_in(:username, :with => "K2")
        fill_in(:password, :with => "K2")
        click_button 'submit'

        visit '/flight_records/new'
        fill_in(:date, :with => Date.today.to_s)
        fill_in(:aircraft_type, :with => "SR22")
        fill_in(:from, :with => "KFLY")
        fill_in(:to, :with => "KCOS")
        fill_in(:remarks, :with => "Test suite remark")
        fill_in(:num_landings, :with => -1)
        fill_in(:duration, :with => 20)


        click_button 'submit'

        expect(page.body).to include('Create a new Flight record')

      end

      it 'will not allow creation of a FR with 0 duration' do
        k2 = User.create(username: "K2", password: "K2")
        k2.flight_records << FlightRecord.create(
          date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "K2's flight", num_landings: 1, duration: 60)
        k2.flight_records << FlightRecord.create(
          date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "Fun flight", num_landings: 1, duration: 60)

        visit '/login'

        fill_in(:username, :with => "K2")
        fill_in(:password, :with => "K2")
        click_button 'submit'

        visit '/flight_records/new'
        fill_in(:date, :with => Date.today.to_s)
        fill_in(:aircraft_type, :with => "SR22")
        fill_in(:from, :with => "KFLY")
        fill_in(:to, :with => "KCOS")
        fill_in(:remarks, :with => "Test suite remark")
        fill_in(:num_landings, :with => 1)
        fill_in(:duration, :with => 0)


        click_button 'submit'

        expect(page.body).to include('Create a new Flight record')

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

end
