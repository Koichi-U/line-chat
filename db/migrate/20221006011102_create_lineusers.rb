class CreateLineusers < ActiveRecord::Migration[7.0]
  def change
    create_table :lineusers do |t|
      t.string :displayname
      t.string :userid, unique: true
      t.string :language
      t.string :pictureurl
      t.string :statusmessage
      t.boolean :active, default: true, null: false
      
      t.string :lastmessage
      t.datetime :lastmessagetime
      t.boolean :read, default: false, null: false
      t.integer :readcount, default: 0

      t.timestamps
    end
  end
end
