class Project < ActiveRecord::Base
  belongs_to :user
  has_many :reviews
  has_many :uses
  
  
  
  
  
   validates_presence_of :name,:description,:homepage
  
  
end
