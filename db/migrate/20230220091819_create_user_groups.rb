class CreateUserGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :user_groups do |t|
      t.references :user, index: true
      t.references :group, index: true
      t.timestamps
    end
  end
end
