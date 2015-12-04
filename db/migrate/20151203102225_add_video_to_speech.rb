class AddVideoToSpeech < ActiveRecord::Migration
  def change
      add_column :speeches, :video_resource_url, :string, default: ''
      add_column :speeches, :video_resource_name, :string, default: ''
  end
end
