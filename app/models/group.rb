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
  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9_-]+\z/ }, uniqueness: true
end
