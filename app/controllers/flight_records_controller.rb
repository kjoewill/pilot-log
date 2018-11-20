class FlightRecordsController < ApplicationController

  get '/tweets' do
    if logged_in?
      @tweets = Tweet.all
      @user = current_user
      erb :"tweets/index"
    else
      redirect "/login"
    end
  end

  post '/flight_records' do
    @flight_record = FlightRecord.create(params)
    @flight_record.user = current_user
    if @flight_record.save
      redirect to "/flight_records/#{@flight_record.id}"
    else
      redirect "flight_records/new"
    end
  end

  get '/flight_records/new' do
    if logged_in?
      erb :"flight_records/new"
    else
      redirect "/login"
    end
  end

  get '/flight_records/:id' do
    if @flight_record = FlightRecord.find(params[:id])
      if @flight_record.user == current_user
        erb :"flight_records/show"
      else
        @user = current_user
        erb :"users/show"
      end
    else
      @user = flight_record.user
      erb :"users/show"
    end
  end

  get '/flight_records/:id/edit' do
    if @flight_record = FlightRecord.find(params[:id])
      if @flight_record.user == current_user
        erb :"flight_records/edit"
      else
        @user = current_user
        erb :"users/show"
      end
    else
      @user = current_user
      erb :"users/show"
    end
  end

  post '/flight_records/:id' do
    @flight_record = FlightRecord.find(params[:id])
    @flight_record.update(params)
    if @flight_record.save
      erb :"flight_records/show"
    else
      redirect "flight_records/#{@flight_record.id}/edit"
    end
  end

  post '/flight_records/:id/delete' do
    flight_record = FlightRecord.find(params[:id])
    if flight_record.user == current_user
      FlightRecord.destroy(params[:id])
    end
    redirect "users/#{flight_record.user.slug}"
  end

end
