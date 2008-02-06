require 'BioPortalWebservice'
class DataAccess
  SERVICE = BioPortalWebservice
  
  
  class << self
    
    def getNode(ontology,node_id)
      if CACHE.get("#{param(ontology)}::#{node_id}").nil?
        node = SERVICE.getNode(ontology,node_id)  
        CACHE.set("#{param(ontology)}::#{node_id}",node)
        return node
      else
        return CACHE.get("#{param(ontology)}::#{node_id}")
      end
    end
    
    def getChildNodes(ontology,node_id,associations)
      if CACHE.get("#{param(ontology)}::#{node_id}_children::#{associations}").nil?
        children = SERVICE.getChildNodes(ontology,node_id,associations)
        CACHE.set("#{param(ontology)}::#{node_id}_children::#{associations}",children)
        return children
      else
        puts "-----------"
        puts "Using CACHE"
        puts "------------"
        return CACHE.get("#{param(ontology)}::#{node_id}_children::#{associations}")
      end
    end
    
    def getParentNodes(ontology,node_id,associations)
      if CACHE.get("#{param(ontology)}::#{node_id}_parent::#{associations}").nil?
        parent = SERVICE.getParentNodes(ontology,node_id,associations)
        CACHE.set("#{param(ontology)}::#{node_id}_parent::#{associations}",parent)
        return parent
      else
        puts "-----------"
        puts "Using CACHE"
        puts "------------"
        return CACHE.get("#{param(ontology)}::#{node_id}_parent::#{associations}")
      end
    end
    
    def getTopLevelNodes(ontology)
      if CACHE.get("#{param(ontology)}::_top").nil?
        topNodes = SERVICE.getTopLevelNodes(ontology)
        CACHE.set("#{param(ontology)}::_top",topNodes)
        return topNodes
      else
        puts "-----------"
        puts "Using CACHE"
        puts "------------"
        return CACHE.get("#{param(ontology)}::_top")
      end
    end
    
    def getOntologyList
      if CACHE.get("ontology_list").nil?
        list = SERVICE.getOntologyList
        CACHE.set("ontology_list",list)
        return list
      else
        puts "-----------"
        puts "Using CACHE"
        puts "------------"
        return CACHE.get("ontology_list")
      end
    end
    
    def getOntology(ontology)
      if CACHE.get("#{param(ontology)}::_details").nil?
        details = SERVICE.getOntology(ontology)
        CACHE.set("#{param(ontology)}::_details",details)
        return details
      else
        puts "-----------"
        puts "Using CACHE"
        puts "------------"
        return CACHE.get("#{param(ontology)}::_details")
      end
    end
    
    def getNodeNameContains(ontologies,search)      
      if CACHE.get("#{param(ontologies.join("|"))}::_search::#{search}").nil?
        results = SERVICE.getNodeNameContains(ontologies,search)
        CACHE.set("#{ontologies.join("|")}::_search::#{search}",results)
        return results
      else
        puts "-----------"
        puts "Using CACHE"
        puts "------------"
        return CACHE.get("#{ontologies.join("|")}::_search::#{search}")
      end
    end
    
    def getNetworkNeighborhoodImage(ontology,node_id,associations=nil)
      if CACHE.get("#{param(ontology)}::#{node_id}_nnImage::#{associations}").nil?
        image = SERVICE.getNetworkNeighborhoodImage(ontology,node_id,associations) 
        CACHE.set("#{param(ontology)}::#{node_id}_nnImage::#{associations}",image)
        return image
      else
        puts "-----------"
        puts "Using CACHE"
        puts "------------"
        return CACHE.get("#{param(ontology)}::#{node_id}_nnImage::#{associations}")
      end
    end
    
    def getPathToRootImage(ontology,node_id,associations=nil)
      if CACHE.get("#{param(ontology)}::#{node_id}_ptrImage::#{associations}")
        image = SERVICE.getPathToRootImage(ontology,node_id,associations)  
        CACHE.set("#{param(ontology)}::#{node_id}_ptrImage::#{associations}",image)
        return image
      else
        puts "-----------"
        puts "Using CACHE"
        puts "------------"
        return CACHE.get("#{param(ontology)}::#{node_id}_ptrImage::#{associations}")
      end
    end
    
    def getPathToRoot(entryNode)
      puts "In Path To Root"
      path=[]
      node = entryNode.parent
      
      while !node.nil?
      puts "Adding node to path #{node}"
        path<<node
        node = node.parent
      end
      
      return path
    end
    
    def param(string)
    return string.gsub(" ","_")
  end
  
    
    
  end
  

  
  
end