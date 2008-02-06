class NodeWrapper
 
 
 
  attr_accessor :id
  attr_accessor :name  
  attr_accessor :isActive
  attr_accessor :properties
  attr_accessor :ontology_name 
  attr_accessor :child_size
  attr_accessor :children
  attr_accessor :parent_association

   
   def mapping_count
     Mapping.count(:conditions=>{:source_ont => self.ontology_name, :source_id => self.id})
   end
   
   def note_count
     MarginNote.count(:conditions=>{:ontology_id => self.ontology_name, :concept_id =>self.id})
   end
   
   def initialize(object=nil)
     if object.nil?
       return
     end
   self.name = object.name
   self.id = object.id
   self.isActive = object.isActive
   self.properties = {}
   self.child_size = object.children.to_i
   
   unless object.propertyValuePair.nil?
      for property in object.propertyValuePair
       properties[property.key]= property.value.gsub("[","").gsub("]","")
      end       
   end
    
   end
   
   def networkNeighborhood(relationships = nil)         
     DataAccess.getNetworkNeighborhoodImage(self.ontology_name,self.id,relationships)
   end
   
   def pathToRootImage(relationships = nil)         
     DataAccess.getPathToRootImage(self.ontology_name,self.id,relationships)
   end
   
   def children(relationship=["is_a"])       
     DataAccess.getChildNodes(self.ontology_name,self.id,relationship)
   end
   
   def parent(relationship=["is_a"])
     # Only returning the first instance for now, some concepts have mulitple parents!
     DataAccess.getParentNodes(self.ontology_name,self.id,relationship).first
   end
   
   def path_to_root
     DataAccess.getPathToRoot(self)    
   end
   
   def to_s
     "Node_Name: #{self.name}  Node_ID: #{self.id}"
   end
end