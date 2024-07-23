FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    industry { Faker::Company.industry }
    founder { Faker::Name.name }
    linkedin_url { Faker::Internet.url }
    batch { 'W22' }
  end
end
