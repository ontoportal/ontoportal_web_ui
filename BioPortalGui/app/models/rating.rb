class Rating < ActiveRecord::Base
  belongs_to :review
  belongs_to :rating_type
end
