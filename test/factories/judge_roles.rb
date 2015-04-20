FactoryGirl.define do
  factory :judge_role do
    name "Chief Justice"
    after :build do |role, evaluator|
      role.organisations = [FactoryGirl.build(:court)] unless evaluator.organisations.any?
    end
  end
end
