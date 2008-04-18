class Project < ActiveRecord::Base
  belongs_to :user
  has_many :reviews, :dependent=>:delete_all
  has_many :uses, :dependent=>:delete_all
  
  
  
  
  
   validates_presence_of :name,:description,:homepage
  
  
end
