class AddActivityIdToSpeech < ActiveRecord::Migration
  def change
    add_column :speeches, :event_id, :integer
  end
end
