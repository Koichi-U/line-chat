class CreateLineusers < ActiveRecord::Migration[7.0]
  def change
    create_table :lineusers do |t|
      t.string :displayName
      t.string :userid
      t.string :language
      t.string :pictureurl
      t.string :statusmessage
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end