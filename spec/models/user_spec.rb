require 'pry'

describe 'User' do
  before do
    @user = User.create(:username => "K2", :password => "K2")
    @user.flight_records << FlightRecord.create(
      date: Date.today - 1, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "K2's flight", num_landings: 1, duration: 60)
    @user.flight_records << FlightRecord.create(
      date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "K2's flight", num_landings: 1, duration: 60)

  end

  it 'has a secure password' do
    expect(@user.authenticate("dog")).to eq(false)
    expect(@user.authenticate("K2")).to eq(@user)
  end

  it 'calculates total number of flights' do
    expect(@user.number_of_flights).to eq(2)
  end

end
