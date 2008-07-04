class Mapping < ActiveRecord::Base
  



  def source_node
    DataAccess.getNode(self.source_ont,self.source_id)
  end
  
  def dest_node
    DataAccess.getNode(self.destination_ont,self.destination_id)
  end


  
  def user
    return DataAccess.getUser(self.user_id)
  end
end
