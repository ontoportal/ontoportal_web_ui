require "rexml/document"
require 'open-uri'

class OntrezService
  
  #   \# = CONCEPT_ID  
  #    @ = Ontology Name
  
  ONTREZ_URL="http://ncbolabs-dev2.stanford.edu:8080/Ontrez_v1_API"
  #ONTREZ_URL="http://171.65.32.224:8080/Ontrez_v1_API"
  CLASS_STRING="/result/ontology/@/classID/#/from/0/number/15/metadata"
  CUI_STRING="/result/cui/#/from/0/number/15/metadata"
  NEXTBIO_URL="http://www.nextbio.com/b/api/searchcount.api?q=#&details=true&apikey=2346462a645f102ba7f2001d096b4f04&type=study"
    
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
    
    
    
      def self.parseNextBio(text)
        doc = REXML::Document.new(open(NEXTBIO_URL.gsub("#",text.gsub(" ","%20"))))
        resource = Resource.new   
        resource.context_numbers = {}
        resource.annotations = []
        resource.name ="NextBio"
        resource.url="http://www.nextbio.com/b/home/generalSearch.nb?q=#{text}#sitype=STUDY"
        resource.description ="NextBio's data
        and literature search engine makes massive amounts of disparate
        biological, clinical and chemical data from public and proprietary
        sources searchable, regardless of data type and origin, empowering
        researchers to quickly understand their own experimental results
        within the context of other research."
        resource.logo ="http://www.nextbio.com/b/s/images2/common/nbLogoSmBeta.png"
        resource.count = doc.elements["NBResultSummary"].elements["count"].get_text.value.to_i
          doc.elements.each("*/details"){ |detail| 
              detail.elements.each { |element| 
                resource.context_numbers[element.name]=element.get_text.value          
              }
            }
          doc.elements.each("*/results"){ |results|
              results.elements.each { |result|
                annotation = Annotation.new
                annotation.local_id = result.elements["name"].get_text.value unless result.elements["name"].nil?
                annotation.term_id = result.elements["name"].get_text.value unless result.elements["name"].nil?
                annotation.item_key = result.elements["name"].get_text.value unless result.elements["name"].nil?
                annotation.url = result.elements["url"].get_text.value unless result.elements["url"].nil?
               
                  annotation.description =  result.elements["name"].get_text.value
                                 
                  #annotation.description = result.elements["title"].get_text.value
                
                
                resource.annotations << annotation            
                }
            
            }  
        return resource  
      end
    
      def self.gatherResourcesByCui(cui)
      resources = []

      doc = REXML::Document.new(open(ONTREZ_URL+CUI_STRING.gsub("#",cui)))
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


OntrezService.parseNextBio("cell")
