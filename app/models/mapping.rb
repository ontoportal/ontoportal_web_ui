class Mapping < ActiveRecord::Base
  
  has_many :margin_notes



  def source_node
    #view = DataAccess.getOntology(self.source_version_id).isView
    return DataAccess.getNode(self.source_version_id,self.source_id)
  end
  
  def dest_node
    #view = DataAccess.getOntology(self.destination_version_id).isView
    return DataAccess.getNode(self.destination_version_id,self.destination_id) rescue nil
  end

  def after_create
    CACHE.delete("#{self.source_ont}::#{self.source_id}_MappingCount")
  end
  
  def user
    return DataAccess.getUser(self.user_id)
  end
  
  
  def ontology
    DataAccess.getOntology(self.source_version_id)
  end
end
