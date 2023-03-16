class CreateUserChats < ActiveRecord::Migration[7.0]
  def change
    create_table :user_chats do |t|
      t.references :user, index: true
      t.references :chat, index: true
      t.timestamps
    end
  end
end
