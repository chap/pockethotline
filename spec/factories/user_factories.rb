FactoryGirl.define do

  sequence :phone do |n|
    n.to_s.rjust(10, "0")
  end

  sequence :email do |n|
    "#{n}@testlifeline.org"
  end

  factory :user, :aliases => [:active_user] do
    name "Alice User"
    phone { generate(:phone) }
    email { generate(:email) }
    password "password"
    pending_approval false

    trait :admin do
      admin true
    end

    trait :deleted do
      deleted_at { 1.day.ago }
    end

    trait :unapproved do
      pending_approval true
    end

    factory :admin_user, :traits => [:admin]
    factory :deleted_user, :traits => [:deleted]
    factory :applying_user, :traits => [:unapproved]
  end
end