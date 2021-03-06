require 'pry'

describe 'User' do
  before do
    @user = User.create(:username => "K2", :password => "K2")
    @user.flight_records << FlightRecord.create(
      date: Date.today - 1, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "K2's flight", num_landings: 1, duration: 60)
    @user.flight_records << FlightRecord.create(
      date: Date.today, aircraft_type: "SR20", from: "KFLY", to: "KCOS", remarks: "K2's flight", num_landings: 17, duration: 90)

  end

  it 'has a secure password' do
    expect(@user.authenticate("dog")).to eq(false)
    expect(@user.authenticate("K2")).to eq(@user)
  end

  it 'calculates total number of flights' do
    expect(@user.number_of_flights).to eq(2)
  end

  it 'calculates cumulative flight hours' do
    expect(@user.flight_hours).to eq(2.5)
  end

  it 'calculates cumulative number of landings' do
    expect(@user.number_of_landings).to eq(18)
  end

end
