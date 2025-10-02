class CreateEmailTracks < ActiveRecord::Migration[8.0]
  def change
    create_table :email_tracks do |t|
      t.string :email
      t.datetime :tracked_at

      t.timestamps
    end
  end
end
