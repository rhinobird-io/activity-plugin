class CreateComment < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :user
      t.belongs_to :speech, index: true
      t.string :comment
      t.string :step
      t.timestamps
    end
  end

  Speech.connection.execute("update speeches set status = 'auditing' where status = 'new'")
end
