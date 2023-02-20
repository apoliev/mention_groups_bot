class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :telegram_user_id
      t.string :telegram_username
      t.string :name
      t.timestamps
    end
  end
end
