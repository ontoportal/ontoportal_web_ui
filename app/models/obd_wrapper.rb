require 'OntrezService'

class OBDWrapper

  
  def self.gatherResources(ontology,concept)
    if CACHE.get("#{ontology}::#{concept.id}_resource").nil?
      begin
        resources = OntrezService.gatherResources(ontology,concept.id.to_s.gsub("_",":"))
        resources << OntrezService.parseNextBio(concept.name)
        CACHE.set("#{ontology}::#{concept.id}_resource",resources)
        puts "resources are : #{resources.inspect}"
        return resources
      rescue Exception => e
        Notifier.deliver_error(e)
        puts e.backtrace.join("\n")
        return []
      end
                  
    else
      return CACHE.get("#{ontology}::#{concept.id}_resource")
    end
  end
  
  def self.gatherResourcesCui(concept)
    if CACHE.get("CUI::#{concept.properties["UMLS_CUI"]}_resource").nil?
      begin        
        resources = OntrezService.gatherResourcesByCui(concept.properties["UMLS_CUI"])
        resources << OntrezService.parseNextBio(concept.name)
        CACHE.set("CUI::#{concept.properties["UMLS_CUI"]}_resource",resources)
        return resources
      rescue Exception => e
        Notifier.deliver_error(e)
        puts e.backtrace.join("\n")
        return []
      end                  
    else
      return CACHE.get("CUI::#{concept.properties["UMLS_CUI"]}_resource")
    end    
  end
  
  
end