class AddCommentToSpeech < ActiveRecord::Migration
  def change
    add_column :speeches, :comment, :string
  end

  Speech.connection.execute("update speeches set status = 'auditing' where status = 'new'")
end
