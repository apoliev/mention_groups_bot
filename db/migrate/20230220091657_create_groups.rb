class CreateGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.references :chat, index: true
      t.timestamps
    end
  end
end
