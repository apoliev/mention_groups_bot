# == Schema Information
#
# Table name: user_groups
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  group_id   :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UserGroup < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :user_id, uniqueness: { scope: :group_id }
end
