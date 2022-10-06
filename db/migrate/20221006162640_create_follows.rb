class CreateFollows < ActiveRecord::Migration[7.0]
  def change
    create_table :follows do |t|
      t.references :lineusers
      t.integer :active, default: 2, null: false

      t.timestamps
    end
  end
end
