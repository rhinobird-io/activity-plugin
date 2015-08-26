class CreateAttendance < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.belongs_to :user, index: true
      t.belongs_to :speech, index: true
      t.string :role
      t.integer :point
      t.integer :comment

      t.timestamps
    end
  end
end
