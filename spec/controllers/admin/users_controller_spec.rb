require 'rails_helper'

RSpec.describe Admin::UsersController, :type => :controller do

  before(:each) do
    @admin = create(:admin_user)
  end

  describe "#show" do
    it "should return a 401 error if the user is not an admin" do
      user = create(:user)
      allow(User).to receive(:authenticate_from_cookie).and_return(user)
      
      get :show, :id => user.id

      expect(response.status).to eq(401)
      expect(assigns(:user)).to eq(nil)
    end

  end

  describe "#update" do
    it "should update the user's password" do
      user = create(:user)
      allow(User).to receive(:authenticate_from_cookie).and_return(@admin)
      post :update, :id => user.id, :password => "my_new_password"

      expect(User.authenticate(user.email, "my_new_password")).to eq(user)
    end
  end
end