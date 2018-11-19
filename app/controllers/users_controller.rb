class UsersController < ApplicationController

  get '/signup' do
    if !logged_in?
      erb :"users/signup"
    else
      @user = current_user
      erb :"users/show"
    end
  end

  post "/signup" do
		user = User.create(params)

    if user.save && user.authenticate(params[:password])
      session[:user_id] = user.id
      @user = current_user
      erb :"users/show"
		else
			redirect "/signup"
		end
	end

  get "/login" do
    if !logged_in?
      erb :"users/login"
    else
      @user = current_user
      erb :"users/show"
    end
  end

  post "/login" do
    user = User.find_by(:username => params[:username])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      @user = current_user
      erb :"users/show"
    else
      redirect "/login"
    end
  end

  get "/logout" do
    session.clear
    redirect "/login"
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :'/users/show'
  end

end
