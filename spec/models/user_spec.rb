require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validates' do
    it { is_expected.to validate_uniqueness_of(:chat_id).scoped_to(:telegram_user_id) }
  end

  describe 'associations' do
    it { is_expected.to belongs_to(:chat) }
    it { is_expected.to have_many(:user_groups).dependent(:destroy) }
    it { is_expected.to have_many(:groups).through(:user_groups) }
  end
end
