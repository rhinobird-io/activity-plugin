class AddStatusToExchanges < ActiveRecord::Migration
  def change
    add_column :exchanges, :status, :integer
    add_index :exchanges, :status
  end
end
