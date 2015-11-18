class AddStatusToPrize < ActiveRecord::Migration
  def change
    add_column :prizes, :status, :string, default: ''
    add_index :prizes, :status
  end
end
