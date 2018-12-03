class FlightRecordsController < ApplicationController

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
      @user = current_user
      erb :"flight_records/new"
    else
      redirect "/login"
    end
  end

  get '/flight_records/:id' do
    if @flight_record = FlightRecord.find_by(id: params[:id])
      if @flight_record.user == current_user
        erb :"flight_records/show"
      end
    else
      #need an error message here because we could not find it
      redirect "/users/#{current_user.id}"
    end
  end

  get '/flight_records/:id/edit' do
    if @flight_record = FlightRecord.find_by(id: params[:id])
      if @flight_record.user == current_user
        erb :"flight_records/edit"
      end
    else
      #need an error message here because we could not find it
      redirect "/users/#{current_user.id}"
    end
  end

  post '/flight_records/:id' do
    if @flight_record = FlightRecord.find_by(id: params[:id])
      if @flight_record.user == current_user && @flight_record.update(params)
        erb :"flight_records/show"
      end
    else
      redirect "flight_records/#{@flight_record.id}/edit"
    end
  end

  post '/flight_records/:id/delete' do
    flight_record = FlightRecord.find(params[:id])
    if flight_record.user == current_user
      FlightRecord.destroy(params[:id])
    end
    redirect "/users/#{current_user.id}"
  end

end
