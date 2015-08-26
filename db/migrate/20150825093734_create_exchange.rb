class CreateExchange < ActiveRecord::Migration
  def change
    create_table :exchanges do |t|
      t.belongs_to :user, index: true
      t.belongs_to :good, index: true
      t.integer :point
      t.timestamp :exchange_time, index: true

      t.timestamps
    end
  end
end
