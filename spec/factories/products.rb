# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :product do
    tier1_price 500
    tier2_price 300
    tier3_price 200
    tier4_price 100
    tier1_commission 100
    tier2_commission 50
    tier3_commission 20
    tier4_commission 10
    moulding
    size
  end

end
