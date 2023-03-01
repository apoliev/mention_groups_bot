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
require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to allow_value(Faker::Lorem.word.downcase).for(:name) }
    it { is_expected.not_to allow_value(Faker::Lorem.word.upcase).for(:name) }
    it { is_expected.not_to allow_value(Faker::Number.number).for(:name) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:chat) }
    it { is_expected.to have_many(:user_groups).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_groups) }
  end
end
