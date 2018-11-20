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
    binding.pry
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
    if logged_in?
      @flight_record = FlightRecord.find(params[:id])
      erb :"flight_records/show"
    else
      redirect "/login"
    end
  end

  get '/tweets/:id/edit' do
    if logged_in?
      @tweet = Tweet.find(params[:id])
      if @tweet.user == current_user
        erb :"tweets/edit"
      else
        redirect "/tweets"
      end
    else
      redirect "/login"
    end
  end

  post '/tweets/:id' do
    @tweet = Tweet.find(params[:id])
    @tweet.content = params[:content]
    if @tweet.save
      erb :"tweets/show"
    else
      redirect "tweets/#{@tweet.id}/edit"
    end
  end

  post '/flight_records/:id/delete' do
    flight_record = FlightRecord.find(params[:id])
    if flight_record.user == current_user
      FlightRecord.destroy(params[:id])
      @user = flight_record.user
      erb :"users/show"
    else
      redirect "/login"
    end
  end

end
