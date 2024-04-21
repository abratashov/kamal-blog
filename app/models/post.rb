class Post < ApplicationRecord
  mount_uploader :photo, PhotoUploader
  process_in_background :photo # if Rails.env.production?
end
