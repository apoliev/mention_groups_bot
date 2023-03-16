# == Schema Information
#
# Table name: user_chats
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  chat_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UserChat < ApplicationRecord
  belongs_to :user
  belongs_to :chat

  validates :user_id, uniqueness: { scope: :chat_id }
end
