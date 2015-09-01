class AddPointTotalToUser < ActiveRecord::Migration
  def change
    add_column :users, :point_total, :integer
    add_index :users, :point_total
  end
end
