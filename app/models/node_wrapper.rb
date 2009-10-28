require 'uri'
class NodeWrapper
 
 
 
  attr_accessor :id
  attr_accessor :fullId
  attr_accessor :name  
  attr_accessor :isActive
  attr_accessor :properties
  attr_accessor :version_id
  attr_accessor :child_size
  attr_accessor :children
  attr_accessor :parent_association
  attr_accessor :is_browsable

   
   def to_param
     "#{URI.escape(self.id,":/?#!")}"
   end
   
   def ontology_name
     return DataAccess.getOntology(self.version_id).displayLabel
   end
   
   def ontology_id
     return DataAccess.getOntology(self.version_id).ontologyId
   end
   
   def mapping_count
     if CACHE.get("#{self.ontology_id}::#{self.id.gsub(" ","%20")}_MappingCount").nil?
        count = Mapping.count(:conditions=>{:source_ont => self.ontology_id, :source_id => self.id})
        CACHE.set("#{self.ontology_id}::#{self.id.gsub(" ","%20")}_MappingCount",count)
        return count
     else
        return CACHE.get("#{self.ontology_id}::#{self.id.gsub(" ","%20")}_MappingCount")
     end
   
   end
   
   def note_count
     if CACHE.get("#{self.ontology_id}::#{self.id.gsub(" ","%20")}_NoteCount").nil?
        count = MarginNote.count(:conditions=>{:ontology_id => self.ontology_id, :concept_id =>self.id})
        CACHE.set("#{self.ontology_id}::#{self.id.gsub(" ","%20")}_NoteCount",count)
        return count
     else
        return CACHE.get("#{self.ontology_id}::#{self.id.gsub(" ","%20")}_NoteCount")
     end

   end
   
   def initialize(object=nil)
     if object.nil?
       return
     end
   self.name = object.name
   self.id = object.id.gsub(" ","%20")
   self.fullId= object.fullId
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
   
  # def children(relationship=["is_a"])       
  #   DataAccess.getChildNodes(self.ontology_name,self.id,relationship)
  # end
   
   def parent(relationship=["is_a"])
    
     DataAccess.getParentNodes(self.ontology_name,self.id,relationship)
   end
   
   def path_to_root
     DataAccess.getPathToRoot(self.version_id,self.id)    
   end
   
   def to_s
     "Node_Name: #{self.name}  Node_ID: #{self.id}"
   end
end