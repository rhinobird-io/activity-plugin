class AddUserNameToSpeech < ActiveRecord::Migration
  def change
    add_column :speeches, :speaker_name, :string
  end
end
