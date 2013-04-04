FactoryGirl.define do
  factory :address, :aliases => [:billing_address, :shipping_address] do
    first_name "Address1"
    last_name "Address2"
    street_address "Lincoln Street"
    city "City of Joy"
    state "West Bengal"
    zip "100100"
  end
end
