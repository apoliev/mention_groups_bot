# == Schema Information
#
# Table name: chats
#
#  id               :bigint           not null, primary key
#  telegram_chat_id :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require 'rails_helper'

RSpec.describe Chat, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:groups).dependent(:destroy) }
    it { is_expected.to have_many(:users).dependent(:destroy) }
  end
end
