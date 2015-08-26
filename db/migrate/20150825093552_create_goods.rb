class CreateGoods < ActiveRecord::Migration
  def change
    create_table :goods do |t|
      t.string :name
      t.text :description
      t.string :picture
      t.integer :point, index: true

      t.timestamps
    end
  end
end
