# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  telegram_user_id  :string
#  telegram_username :string
#  chat_id           :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class User < ApplicationRecord
  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_many :user_chats, dependent: :destroy
  has_many :chats, through: :user_chats

  with_options presence: true do
    validates :telegram_user_id
    validates :telegram_username
  end

  with_options allow_nil: true, allow_blank: true do
    validates :telegram_user_id, uniqueness: true
    validates :telegram_username, uniqueness: true
  end

  def in_chat?(chat)
    user_chats.where(chat_id: chat).exists?
  end
end
