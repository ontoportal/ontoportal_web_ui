class Review < ActiveRecord::Base
  belongs_to :project
  has_many :ratings, :dependent=>:delete_all
  

  def ontology
    DataAccess.getLatestOntology(self.ontology_id)
  end
  
  def user
    return DataAccess.getUser(self.user_id)
  end
  
  def after_create
     CACHE.delete("#{self.ontology_id}::ReviewCount")
  end
  
end
