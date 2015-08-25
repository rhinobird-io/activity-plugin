class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :role
      t.integer :point

      t.timestamps
    end
    add_index :users, :point
  end
end
