class ChangeUserPoint < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :point, :point_available
      t.integer :point_total, index: true
    end
  end
end
