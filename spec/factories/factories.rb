FactoryGirl.define do

  factory :user do
    password 'password'
  end

  factory :campaign do
    survey
    title 'Campaign title'
  end

  factory :survey do
    title 'Campaign Survey title'
  end

  factory :api_key do
    client_name 'test api'
  end

end