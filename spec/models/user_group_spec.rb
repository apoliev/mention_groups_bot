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
require 'rails_helper'

RSpec.describe UserGroup, type: :model do
  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:group_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
  end
end
