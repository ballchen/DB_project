class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :city
      t.string :country
      t.string :street
      t.string :zip
      t.float :latitude
      t.float :longitude
      t.timestamps
    end
  end
end
