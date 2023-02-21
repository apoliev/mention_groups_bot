# == Schema Information
#
# Table name: groups
#
#  id         :bigint           not null, primary key
#  name       :string
#  chat_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Group < ApplicationRecord
  belongs_to :chat
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups

  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9_-]+\z/ }, uniqueness: true
end
