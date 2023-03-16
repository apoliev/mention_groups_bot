# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  telegram_user_id  :string
#  telegram_username :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
FactoryBot.define do
  factory :user do
    chat
    telegram_user_id { Faker::Lorem.word }
    telegram_username { Faker::Lorem.word }
  end
end
