require 'pry'
describe 'User' do
  before do
    @user = User.create(:username => "test 123", :password => "test")
  end

  it 'has a secure password' do
    expect(@user.authenticate("dog")).to eq(false)
    expect(@user.authenticate("test")).to eq(@user)
  end
end
