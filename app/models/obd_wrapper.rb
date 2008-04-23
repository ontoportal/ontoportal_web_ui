require 'OntrezService'

class OBDWrapper

  
  def self.gatherResources(ontology,concept)
    if CACHE.get("#{ontology}::#{concept}_resource").nil?
      begin
        resources = OntrezService.gatherResources(ontology,concept)
        CACHE.set("#{ontology}::#{concept}_resource",resources)
        puts "resources are : #{resources.inspect}"
        return resources
      rescue Exception => e
        Notifier.deliver_error(e)
        puts e.backtrace.join("\n")
        return []
      end
                  
    else
      return CACHE.get("#{ontology}::#{concept}_resource")
    end
  end
  
  def self.gatherResourcesCui(cui)
    if CACHE.get("CUI::#{cui}_resource").nil?
      begin        
        resources = OntrezService.gatherResourcesByCui(cui)
        CACHE.set("CUI::#{cui}_resource",resources)
        return resources
      rescue Exception => e
        Notifier.deliver_error(e)
        puts e.backtrace.join("\n")
        return []
      end                  
    else
      return CACHE.get("CUI::#{cui}_resource")
    end    
  end
  
  
end