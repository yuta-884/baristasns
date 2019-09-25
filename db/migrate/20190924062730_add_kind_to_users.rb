class AddKindToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :kind, :boolean, default: false, null: false
  end
end
