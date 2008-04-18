class Review < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  has_many :ratings, :dependent=>:delete_all
end
