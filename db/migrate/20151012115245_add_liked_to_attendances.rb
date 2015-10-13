class AddLikedToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :liked, :boolean, default: false
  end
end
