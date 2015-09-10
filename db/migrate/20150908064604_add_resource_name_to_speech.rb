class AddResourceNameToSpeech < ActiveRecord::Migration
  def change
    add_column :speeches, :resource_name, :string
  end
end
