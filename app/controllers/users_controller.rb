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
    if user.save && user.authenticate(params[:password]) && user.authenticate(params[:username])
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
      redirect "/users/#{current_user.id}"
      #@user = current_user
      #erb :"users/show"
    end
  end

  post "/login" do
    user = User.find_by(:username => params[:username])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/users/#{user.id}"
    else
      redirect "/login"
    end
  end

  get "/logout" do
    session.clear
    redirect '/'
  end

  get '/users/:id' do
    if logged_in?
      if @user = User.find(params[:id])
        if @user.id == current_user.id
          erb :'/users/show'
        else
          redirect '/'
        end
      else
        redirect '/'
      end
    else
      redirect '/'
    end
  end

end
