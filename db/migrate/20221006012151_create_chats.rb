class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.string :message
      t.references :user
      t.references :lineuser

      t.timestamps
    end
  end
end
