require "rexml/document"
require 'open-uri'

class OntrezService
  
  #   \# = CONCEPT_ID  
  #    @ = Ontology Name
  
  ONTREZ_URL="http://ncbolabs-dev1.stanford.edu:8080/Ontrez_v1_API"
  #ONTREZ_URL="http://171.65.32.224:8080/Ontrez_v1_API"
  CLASS_STRING="/result/ontology/@/classID/#/from/0/number/15/metadata"
  CUI_STRING="/result/cui/#/from/0/number/15/metadata"
    
    def self.gatherResources(ontology_name,concept_id)
      resources = []

      doc = REXML::Document.new(open(ONTREZ_URL+CLASS_STRING.gsub("@",ontology_name).gsub("#",concept_id)))
#      puts doc.inspect
      puts "Retrieved Doc"
      puts "--------------"
      puts "Beginning Parsing"
      puts doc.inspect
    doc.elements.each("*/resultLines/ontrez\.user\.OntrezResultLine"){ |element|    
      
      resource = Resource.new   
      resource.name = element.elements["lineName"].get_text.value
      resource.url = element.elements["lineURL"].get_text.value
      resource.description = element.elements["lineDescription"].get_text.value
      resource.logo = element.elements["lineLogo"].get_text.value
      resource.count = element.elements["lineNumber"].get_text.value.to_i
      resource.context_numbers = {}
      resource.annotations = [] 
      
      element.elements["lineContextNumbers"].elements.each("entry") { |entry|
          resource.context_numbers[entry.elements["string"].get_text.value]=entry.elements["int"].get_text.value    
      }
    
      element.elements["lineDetailsWithMetadata"].elements["lineAnnotationsForBP"].elements.each("ontrez\.annotation\.AnnotationForBioPortal") {|annot|
          annotation = Annotation.new
          annotation.local_id = annot.elements["elementLocalID"].get_text.value
          annotation.term_id = annot.elements["termID"].get_text.value
          annotation.item_key = annot.elements["itemKey"].get_text.value
          annotation.url = annot.elements["url"].get_text.value
          annotation.description = annot.elements["metaDataText"].get_text.value
        
          resource.annotations << annotation
      }
    
    
      resources << resource
      
      
    }
    puts "Finished Parsing"
    return resources

    end
    
    
      def self.gatherResourcesByCui(cui)
      resources = []

      doc = REXML::Document.new(open(ONTREZ_URL+CLASS_STRING.gsub("#",concept_id)))
#      puts doc.inspect
      puts "Retrieved Doc"
      puts "--------------"
      puts "Beginning Parsing"
      puts doc.inspect
    doc.elements.each("*/resultLines/ontrez\.user\.OntrezResultLine"){ |element|    
      
      resource = Resource.new   
      resource.name = element.elements["lineName"].get_text.value
      resource.url = element.elements["lineURL"].get_text.value
      resource.description = element.elements["lineDescription"].get_text.value
      resource.logo = element.elements["lineLogo"].get_text.value
      resource.count = element.elements["lineNumber"].get_text.value.to_i
      resource.context_numbers = {}
      resource.annotations = [] 
      
      element.elements["lineContextNumbers"].elements.each("entry") { |entry|
          resource.context_numbers[entry.elements["string"].get_text.value]=entry.elements["int"].get_text.value    
      }
    
      element.elements["lineDetailsWithMetadata"].elements["lineAnnotationsForBP"].elements.each("ontrez\.annotation\.AnnotationForBioPortal") {|annot|
          annotation = Annotation.new
          annotation.local_id = annot.elements["elementLocalID"].get_text.value
          annotation.term_id = annot.elements["termID"].get_text.value
          annotation.item_key = annot.elements["itemKey"].get_text.value
          annotation.url = annot.elements["url"].get_text.value
          annotation.description = annot.elements["metaDataText"].get_text.value
        
          resource.annotations << annotation
      }
    
    
      resources << resource
      
      
    }
    puts "Finished Parsing"
    return resources

    end
    
  
  
 
   
end

