class ChangeUserPoint < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :point, :point_available
    end
  end
end
