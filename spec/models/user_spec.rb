# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  telegram_user_id  :string
#  telegram_username :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validates' do
    it { is_expected.to validate_presence_of(:telegram_username) }
    it { is_expected.to validate_presence_of(:telegram_user_id) }
    it { is_expected.to validate_uniqueness_of(:telegram_username) }
    it { is_expected.to validate_uniqueness_of(:telegram_user_id) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:user_chats).dependent(:destroy) }
    it { is_expected.to have_many(:user_groups).dependent(:destroy) }
    it { is_expected.to have_many(:groups).through(:user_groups) }
    it { is_expected.to have_many(:chats).through(:user_chats) }
  end
end
