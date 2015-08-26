class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :role
      t.integer :point, index: true

      t.timestamps
    end
  end
end
