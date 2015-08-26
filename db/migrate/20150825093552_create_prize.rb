class CreatePrize < ActiveRecord::Migration
  def change
    create_table :prizes do |t|
      t.string :name
      t.text :description
      t.string :picture_url
      t.integer :price, index: true

      t.timestamps
    end
  end
end
