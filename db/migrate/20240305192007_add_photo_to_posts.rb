class AddPhotoToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :photo, :string
  end
end
