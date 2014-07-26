# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sheet do
    is_public? false
    is_flagged? false
    is_free? false
    is_original? false
    price "9.99"
    title "MyString"
    pages 1
    uploader ""
    description "MyText"
  end
end
