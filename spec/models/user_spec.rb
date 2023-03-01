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
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validates' do
    it { is_expected.to validate_uniqueness_of(:chat_id).scoped_to(:telegram_user_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:chat) }
    it { is_expected.to have_many(:user_groups).dependent(:destroy) }
    it { is_expected.to have_many(:groups).through(:user_groups) }
  end

  describe '::with_username' do
    context 'when with username' do
      let!(:user) { create(:user) }

      it do
        expect(described_class.with_username).to eq([user])
      end
    end

    context 'when without username' do
      let!(:user) { create(:user, telegram_username: nil) }

      it do
        expect(described_class.with_username).to be_empty
      end
    end
  end
end
