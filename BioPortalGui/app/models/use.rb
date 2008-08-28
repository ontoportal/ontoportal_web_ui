class Use < ActiveRecord::Base
  belongs_to :project
  
  
  def ontology
    DataAccess.getLatestOntology(self.ontology_id)
  end


end
