class AddReplyToMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :messages, :reply, foreign_key: { to_table: :messages }, default: nil
  end
end
