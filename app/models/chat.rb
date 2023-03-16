# == Schema Information
#
# Table name: chats
#
#  id               :bigint           not null, primary key
#  telegram_chat_id :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Chat < ApplicationRecord
  has_many :groups, dependent: :destroy
  has_many :user_chats, dependent: :destroy
  has_many :users, through: :user_chats
end
