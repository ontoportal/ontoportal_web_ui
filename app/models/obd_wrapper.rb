require 'OntrezService'

class OBDWrapper

  
  def self.gatherResources(ontology,concept)
    if CACHE.get("#{ontology}::#{concept.id}_resource").nil?
      resources=[]
      cache=true
      begin
        resources << OntrezService.gatherResources(ontology,concept.id.to_s.gsub("_",":"))
      rescue Exception => e
        cache=false
          Notifier.deliver_error(e)
          puts e.backtrace.join("\n")
      end
      begin
        resources << OntrezService.parseNextBio(concept.name)              
      rescue Exception => e
        cache=false
        Notifier.deliver_error(e)
        puts e.backtrace.join("\n")      
      end
      if cache
        CACHE.set("#{ontology}::#{concept.id}_resource",resources)
      end
        puts "resources are : #{resources.inspect}"
        return resources
    else
      return CACHE.get("#{ontology}::#{concept.id}_resource")
    end
  end
  
  def self.gatherResourcesCui(concept)
    if CACHE.get("CUI::#{concept.properties["UMLS_CUI"]}_resource").nil?
      resources = []
      cache=true
      begin        
        resources = OntrezService.gatherResourcesByCui(concept.properties["UMLS_CUI"])
      rescue Exception => e
          cache=false
          Notifier.deliver_error(e)
          puts e.backtrace.join("\n")
          return []
      end
      begin
        resources << OntrezService.parseNextBio(concept.name)
        rescue Exception => e
          cache=false
          Notifier.deliver_error(e)
          puts e.backtrace.join("\n")
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
  
  
end