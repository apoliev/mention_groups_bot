# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  telegram_user_id  :string
#  telegram_username :string
#  name              :string
#  chat_id           :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class User < ApplicationRecord
  belongs_to :chat
  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups

  validates :chat_id, uniqueness: { scope: :telegram_user_id }

  scope :with_username, -> { where.not(telegram_username: nil) }
end
