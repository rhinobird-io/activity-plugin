class CreateSpeech < ActiveRecord::Migration
  def change
    create_table :speeches do |t|
      t.string :name
      t.text :description
      t.belongs_to :user, index: true
      t.string :slides
      t.integer :expected_duration
      t.timestamp :speech_time, index: true
      t.integer :status
      t.integer :category, index: true

      t.timestamps
    end
  end
end
