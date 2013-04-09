FactoryGirl.define do
  factory :user_device do
    last_notified { DateTime.now }
    device_token "MyString"
    user
  end
end
