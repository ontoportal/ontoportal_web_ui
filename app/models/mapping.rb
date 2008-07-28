class Mapping < ActiveRecord::Base
  



  def source_node
    DataAccess.getNode(self.source_version_id,self.source_id)
  end
  
  def dest_node
    DataAccess.getNode(self.destination_version_id,self.destination_id)
  end

  def after_create
    CACHE.delete("#{self.source_ont}::#{self.source_id}_MappingCount")
  end
  
  def user
    return DataAccess.getUser(self.user_id)
  end
end
