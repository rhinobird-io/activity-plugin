class CreateAudience < ActiveRecord::Migration
  def change
    create_table :audiences do |t|
      t.belongs_to :user, index: true
      t.belongs_to :speech, index: true

      t.timestamps
    end
  end
end
