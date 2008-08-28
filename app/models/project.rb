class Project < ActiveRecord::Base
  belongs_to :user
  has_many :reviews, :dependent=>:delete_all
  has_many :uses, :dependent=>:delete_all
  
  
  
  
  
   validates_presence_of :name,:description,:homepage
  
  
  def after_create
    for use in self.uses
      CACHE.delete("#{use.ontology_id}::ProjectCount")      
    end
  end
end
