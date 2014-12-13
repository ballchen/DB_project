class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :pic
      t.timestamps
      t.json :been_to
    end
    add_column :users, :data_id, :bigint
    add_index :users, :data_id, :unique => true
  end
end
