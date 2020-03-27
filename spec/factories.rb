FactoryBot.define do
  factory :user do
    sequence(:email){|n| "email#{n}@example.com"}
    password "validEmail1"
    first_name "Name"
    last_name "Surname"
    confirmed_at Time.now

    [:tenant, :admin, :partner, :customer].each_with_index do |profile, index|
      factory "#{profile}_user".to_sym do
        profile_type index
      end
    end

    trait :accepted_terms do
      accept_terms true
    end
  end

  factory :company do
    sequence(:name){|n| "company#{n}"}
    sequence(:email){|n| "office#{n}@company.com"}
    sequence(:vat_number){|n| "vat#{n}"}

    contact_person "Contact Person Name"
    phone "1234567890"
    mobile "1234567890"

    [:admin, :partner, :customer].each_with_index do |type, index|
      factory "#{type}_company".to_sym do
        company_type index
      end
    end

    trait :with_location do
      association :location, factory: :location
    end

    association :business
  end

  factory :employee do
    sequence(:current_first_name) { |n| "current_first_name#{n}" }
    sequence(:current_last_name) { |n| "current_last_name#{n}" }
    current_monthly_hours 20
    current_work_type 0

    association :customer, class_name: "Company"
  end

  factory :business do
    sequence(:name){|n| "business#{n}"}
  end

  factory :company_with_customer do
    create :company_company

    after :create do |company|
      create :customer_company, parent_id: company_id
    end
  end

  factory :evaluation do
    sequence(:name){|n| "company#{n}"}
    association :company
  end

  factory :service do
    sequence(:code){|n| "code#{n}"}
    sequence(:name){|n| "name#{n}"}
    sequence(:purpose){|n| "purpose#{n}"}
    sequence(:position){|n| "#{n}"}
  end

  factory :evaluation_service do
    association :service
    association :evaluation
  end

  factory :location do
    sequence(:address){|n| "address#{n}"}
    city 'City'
    country 'Country'
    zip '2000'
  end

  factory :company_branch do
    sequence(:name){|n| "branch#{n}"}

    association :company

    after(:build) do |company_branch|
      company_branch.location ||= FactoryBot.build(:location)
    end
  end

  factory :evaluation_result do
    association :evaluation
    association :company_branch
    association :service
  end

  factory :company_user do
    association :company
    association :user
  end
end
