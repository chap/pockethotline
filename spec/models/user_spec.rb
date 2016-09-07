require "rails_helper"

RSpec.describe User, :type => :model do
  context "validity" do

    it "should be invalid if the email is a dupe of a user's" do
      user = create(:applying_user)

      new_user = build(:user, :email => user.email)
      expect(new_user).to_not be_valid
    end

    it "should be valid if the email is a dupe of a deleted user" do
      user = create(:deleted_user)

      new_user = build(:user, :email => user.email)
      expect(new_user).to be_valid
    end

    context "phone" do
    
      it "should be invalid if the phone number is a dupe of a user's" do
        user = create(:user)

        new_user = build(:user, :phone => user.phone)
        expect(new_user).to_not be_valid
      end

      it "should be valid if the phone number is a dupe of a deleted user's" do
        user = create(:deleted_user)

        new_user = build(:user, :phone => user.phone)
        expect(new_user).to be_valid
      end

      it "should be invalid if the phone is missing" do
        user = build(:user, :phone => nil)
        expect(user).to_not be_valid
      end

      it "should be valid for no phone if the admin is creating the user" do
        user = build(:user, :phone => nil)
        user.admin_creating_user = true
        expect(user).to be_valid
      end
    end
  end
end