# == Schema Information
#
# Table name: users
#
#  id               :bigint           not null, primary key
#  telegram_user_id :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class User < ApplicationRecord
end
