class AddExchangedTimesToPrizes < ActiveRecord::Migration
  def change
    add_column :prizes, :exchanged_times, :integer
    add_index :prizes, :exchanged_times
  end
end
