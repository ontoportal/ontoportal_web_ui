require 'BioPortalWebservice'
class DataAccess
  SERVICE = BioPortalWebservice #sets what backend we are using
  
  
    
    def self.getNode(ontology,node_id)
      if CACHE.get("#{param(ontology)}::#{node_id}").nil?
        node = SERVICE.getNode(ontology,node_id)  
        CACHE.set("#{param(ontology)}::#{node_id}",node)
        return node
      else
        return CACHE.get("#{param(ontology)}::#{node_id}")
      end
    end
    
    def self.getChildNodes(ontology,node_id,associations)
      if CACHE.get("#{param(ontology)}::#{node_id}_children::#{associations}").nil?
        children = SERVICE.getChildNodes(ontology,node_id,associations)
        CACHE.set("#{param(ontology)}::#{node_id}_children::#{associations}",children)
        return children
      else        
        return CACHE.get("#{param(ontology)}::#{node_id}_children::#{associations}")
      end
    end
    
    def self.getParentNodes(ontology,node_id,associations)
      if CACHE.get("#{param(ontology)}::#{node_id}_parent::#{associations}").nil?
         # Only returning the first instance for now, some concepts have mulitple parents!
        parent = SERVICE.getParentNodes(ontology,node_id,associations).first
        puts "Setting Parent to #{parent.inspect}"
        CACHE.set("#{param(ontology)}::#{node_id}_parent::#{associations}",parent)
        return parent
      else
        return CACHE.get("#{param(ontology)}::#{node_id}_parent::#{associations}")
      end
    end
    
    def self.getTopLevelNodes(ontology)
      if CACHE.get("#{param(ontology)}::_top").nil?
        topNodes = SERVICE.getTopLevelNodes(ontology)
        CACHE.set("#{param(ontology)}::_top",topNodes)
        return topNodes
      else
        return CACHE.get("#{param(ontology)}::_top")
      end
    end
    
    def self.getOntologyList
      if CACHE.get("ontology_list").nil?
        list = SERVICE.getOntologyList
        CACHE.set("ontology_list",list)
        return list
      else
        return CACHE.get("ontology_list")
      end
    end
    
    def self.getOntology(ontology)
      if CACHE.get("#{param(ontology)}::_details").nil?
        details = SERVICE.getOntology(ontology)
        CACHE.set("#{param(ontology)}::_details",details)
        return details
      else
        return CACHE.get("#{param(ontology)}::_details")
      end
    end
    
    def self.getNodeNameSoundsLike(ontologies,search)
      if CACHE.get("#{param(ontologies.join("|"))}::_searchsound::#{param(search)}").nil?
        results = SERVICE.getNodeNameContains(ontologies,search)
        CACHE.set("#{param(ontologies.join("|"))}::_searchsound::#{param(search)}",results)
        return results
      else
        return CACHE.get("#{param(ontologies.join("|"))}::_searchsound::#{param(search)}")
      end
    end
    
    def self.getNodeNameContains(ontologies,search)      
      if CACHE.get("#{param(ontologies.join("|"))}::_search::#{param(search)}").nil?
        results = SERVICE.getNodeNameContains(ontologies,search)
        CACHE.set("#{param(ontologies.join("|"))}::_search::#{param(search)}",results)
        return results
      else
        return CACHE.get("#{param(ontologies.join("|"))}::_search::#{param(search)}")
      end
    end
    
    def self.getAttributeValueContains(ontologies,search)
       if CACHE.get("#{param(ontologies.join("|"))}::_searchAttrCont::#{param(search)}").nil?
        results = SERVICE.getAttributeValueContains(ontologies,search)
        CACHE.set("#{param(ontologies.join("|"))}::_searchAttrCont::#{param(search)}",results)
        return results
      else
        return CACHE.get("#{param(ontologies.join("|"))}::_searchAttrCont::#{param(search)}")
      end
      
      
    end
    
    def self.getAttributeValueSoundsLike(ontologies,search)
       if CACHE.get("#{param(ontologies.join("|"))}::_searchAttrSound::#{param(search)}").nil?
        results = SERVICE.getAttributeValueSoundsLike(ontologies,search)
        CACHE.set("#{param(ontologies.join("|"))}::_searchAttrSound::#{param(search)}",results)
        return results
      else
        return CACHE.get("#{param(ontologies.join("|"))}::_searchAttrSound::#{param(search)}")
      end
      
      
    end
    
    
    
    
    def self.getNetworkNeighborhoodImage(ontology,node_id,associations=nil)
      if CACHE.get("#{param(ontology)}::#{node_id}_nnImage::#{associations}").nil?
        image = SERVICE.getNetworkNeighborhoodImage(ontology,node_id,associations) 
        CACHE.set("#{param(ontology)}::#{node_id}_nnImage::#{associations}",image)
        return image
      else
        return CACHE.get("#{param(ontology)}::#{node_id}_nnImage::#{associations}")
      end
    end
    
    def self.getPathToRootImage(ontology,node_id,associations=nil)
      if CACHE.get("#{param(ontology)}::#{node_id}_ptrImage::#{associations}").nil?
        image = SERVICE.getPathToRootImage(ontology,node_id,associations) 
        CACHE.set("#{param(ontology)}::#{node_id}_ptrImage::#{associations}",image)
        return image
      else
        return CACHE.get("#{param(ontology)}::#{node_id}_ptrImage::#{associations}")
      end
    end
    
    def self.getPathToRoot(entryNode)      
      path=[]
      node = entryNode.parent
      puts "Parent is #{node}"
      
      while !node.nil?
        path<<node
        node = node.parent
      end
      
      return path
    end
    
    def self.param(string)
      return string.gsub(" ","_")
    end
   
  
end