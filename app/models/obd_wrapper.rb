require 'OntrezService'

class OBDWrapper

  
  def self.gatherResources(ontology,concept)
    if CACHE.get("#{ontology}::#{concept}_resource").nil?
       #begin
        
        resources = OntrezService.gatherResources(ontology,concept)
        CACHE.set("#{ontology}::#{concept}_resource",resources)
        return resources
      # rescue Exception => e
      #  puts e 
       #   return []
      # end
                  
    else
      return CACHE.get("#{ontology}::#{concept}_resource")
    end
  end
  
  
end