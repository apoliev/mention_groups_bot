# == Schema Information
#
# Table name: chats
#
#  id               :bigint           not null, primary key
#  telegram_chat_id :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
FactoryBot.define do
  factory :chat do
    telegram_chat_id { Faker::Lorem.word }
  end
end
