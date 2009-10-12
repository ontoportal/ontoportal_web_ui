require 'OntrezService'

class OBDWrapper

   NO_CACHE = true
   
  def self.gatherResources(ontology,concept,latest,version_id)
    if CACHE.get("#{ontology}::#{concept.id}_resource").nil? || NO_CACHE 
      resources=[]
      cache=true
      begin
        resources = OntrezService.gatherResources(ontology,concept.id,latest,version_id)
      rescue Exception => e
        cache=false
        
#          Notifier.deliver_error(e)
          #puts e.message
          #puts e.backtrace.join("\n")
      end
      # makes it so no resources show if ontrez is broken
      if resources.empty?
        return resources
      end
      
      begin
        resources << OntrezService.parseNextBio(concept.name)              
      rescue Exception => e
        cache=false
        Notifier.deliver_error(e)
        #puts e.backtrace.join("\n")      
      end
      if cache
        CACHE.set("#{ontology}::#{concept.id}_resource",resources)
      end
        return resources
    else
      return CACHE.get("#{ontology}::#{concept.id}_resource")
    end
  end
  
  def self.gatherResourcesDetails(ontology_id,latest,version_id,concept_id,resource,element)  
      details = OntrezService.gatherResourcesDetails(ontology_id,latest,version_id,concept_id,resource,element)
      return details
  end
  
  
  def self.gatherResourcesCui(concept)
    if CACHE.get("CUI::#{concept.properties["UMLS_CUI"]}_resource").nil?  || NO_CACHE 
      resources = []
      cache=true
      begin        
        resources = OntrezService.gatherResourcesByCui(concept.properties["UMLS_CUI"])
      rescue Exception => e
          cache=false
          Notifier.deliver_error(e)
          #puts e.backtrace.join("\n")
          return []
      end
      begin
        resources << OntrezService.parseNextBio(concept.name)
        rescue Exception => e
          cache=false
          Notifier.deliver_error(e)
          #puts e.backtrace.join("\n")
          return []
        end
        if cache
          CACHE.set("CUI::#{concept.properties["UMLS_CUI"]}_resource",resources)
        end
        return resources               
    else
      return CACHE.get("CUI::#{concept.properties["UMLS_CUI"]}_resource")
    end    
  end
  
  def self.pageResources(ontology_id,latest,version_id,concept_id,resource_name,resource_main_context,page_start,page_end)
    resource = Resource.new

    begin        
      resource = OntrezService.pageResources(ontology_id,latest,version_id,concept_id,resource_name,resource_main_context,page_start,page_end)
        rescue Exception => e
      
            Notifier.deliver_error(e)
            #puts e.backtrace.join("\n")
            return resource
        end
  end
  
  
end