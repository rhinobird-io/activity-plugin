class CreateSpeech < ActiveRecord::Migration
  def change
    create_table :speeches do |t|
      t.string :title
      t.text :description
      t.belongs_to :user, index: true
      t.string :resource_url
      t.integer :expected_duration
      t.timestamp :time, index: true
      t.string :status
      t.string :category, index: true

      t.timestamps
    end
  end
end
