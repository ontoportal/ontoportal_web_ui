require "rexml/document"
require 'open-uri'

class OntrezService
  
  #   \# = CONCEPT_ID  
  #    @ = Ontology Name
  #  *R* = Resource Name
  #   $S$= pageStart
  #   $E$ = Page End
  
  
  ONTREZ_URL="http://ncbolabs-dev2.stanford.edu:8080/Ontrez_v1_API"
  #ONTREZ_URL="http://171.65.32.224:8080/Ontrez_v1_API"
  CLASS_STRING="/result/ontology/@/classID/#/from/0/number/15/metadata"
  CUI_STRING="/result/cui/#/from/0/number/15/metadata"
  NEXTBIO_URL="http://www.nextbio.com/b/api/searchcount.api?q=#&details=true&apikey=2346462a645f102ba7f2001d096b4f04&type=study"
  
  PAGING_CLASS_STRING ="/result/ontology/@/classID/#/from/$S$/number/$E$/resource/*R*/metadata"
  PAGING_CUI_STRING="/result/cui/#/from/$S$/number/$E$/resource/*R*/metadata"
  

  def self.gatherResources(ontology_version_id,concept_id)
    resources = []
    puts "===================================="
  #  puts "Gathering Resource From URL: #{ONTREZ_URL+CLASS_STRING.gsub("@",ontology_name).gsub("#",concept_id)}"
    puts "===================================="
    
    oba_url = "http://ncbolabs-dev2.stanford.edu:8080/OBS_v1/obr/@/#/PGGE/false/1/10"
    
    doc = REXML::Document.new(open(oba_url.gsub("@",ontology_version_id.to_s).gsub("#",concept_id)))

    puts "Beginning Parsing"
    
  #  puts doc.inspect
    resources = parseOBS(doc)
  
  
  puts "Resources: \n #{resources.inspect}"
  puts "Finished Parsing"
  return resources

  end



  
  
    def self.gatherResources_old(ontology_name,concept_id)
      resources = []
      puts "===================================="
      puts "Gathering Resource From URL: #{ONTREZ_URL+CLASS_STRING.gsub("@",ontology_name).gsub("#",concept_id)}"
      puts "===================================="
      doc = REXML::Document.new(open(ONTREZ_URL+CLASS_STRING.gsub("@",ontology_name.gsub(" ","%20")).gsub("#",concept_id)))

      puts "Beginning Parsing"
      
    #  puts doc.inspect
      resources = parseResources(doc)
    
    puts "Finished Parsing"
    return resources

    end
    
    def self.pageResources(ontology_name,concept_id,resource_name,page_start,page_end)
      resources=[]
      
      puts "Parsing URL #{ONTREZ_URL+PAGING_CLASS_STRING.gsub("@",ontology_name.gsub(" ","%20")).gsub("#",concept_id).gsub("$S$",page_start).gsub("$E$",page_end).gsub("*R*",resource_name)}"
         doc = REXML::Document.new(open(ONTREZ_URL+PAGING_CLASS_STRING.gsub("@",ontology_name.gsub(" ","%20")).gsub("#",concept_id).gsub("$S$",page_start).gsub("$E$",page_end).gsub("*R*",resource_name)))

          puts "Beginning Parsing"

          puts doc
          resources = parseAnnotations(doc)

          return resources

    end

    def self.pageResourcesByCui(cui,resource_name,page_start,page_end)
    
    end

    
    
      def self.parseNextBio(text)
        doc = REXML::Document.new(open(NEXTBIO_URL.gsub("#",text.gsub(" ","%20").gsub("_","%20"))))
#        puts "NextBIO URL:#{NEXTBIO_URL.gsub("#",text.gsub(" ","%20").gsub("_","%20"))}"
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
      puts "URL:------#{ONTREZ_URL+CUI_STRING.gsub("#",cui)}----------"
      puts "Retrieved Doc"
      puts "--------------"
      puts "Beginning Parsing"
      time=Time.now
   #   puts doc.inspect
    resources = parseResources(doc)
    puts "Finished Parsing #{Time.now-time}"

    return resources 

    end
    
 private 
 
 
 def self.parseOBS(doc)
   resources =[]
   
    resource =  Resource.new
    resource.name = "The Pharmacogenetics and Pharmacogenomics Knowledge Base"
    resource.shortname = "PGGE"
    resource.url = "http://www.pharmgkb.org/"
    resource.description = "PharmGKB curates information that establishes knowledge about the relationships among drugs, diseases and genes, including their variations and gene products."
    resource.logo = "https://www.pharmgkb.org/images/header/title.png"
    
    doc.elements.each("*/statistics/obs\.common\.beans\.StatisticsBean"){ |statistic|
        resource.count = statistic.elements["nbAnnotation"].get_text.value.to_i      
      }
    
    resource.context_numbers = {}
    resource.annotations = []
    
    resources << resource

 end
 
 def self.parseResources(doc)
 resources =[]
 doc.elements.each("*/resultLines/ontrez\.user\.OntrezResultLine"){ |element|    
   
   resource = Resource.new   
   resource.name = element.elements["lineName"].get_text.value
   resource.shortname = element.elements["lineShortName"].get_text.value   
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
 return resources
 
 
 
 end 
 
  private 
  
  def self.parseAnnotations(doc)
  resources =[]
  doc.elements.each("/ontrez\.user\.OntrezResultDetailsWithMetadata/lineAnnotationsForBP/ontrez\.annotation\.AnnotationForBioPortal"){ |element|    

    puts "Parsing an annotation"

        annotation = Annotation.new
        annotation.local_id = element.elements["elementLocalID"].get_text.value
        annotation.term_id = element.elements["termID"].get_text.value
        annotation.item_key = element.elements["itemKey"].get_text.value
        annotation.url = element.elements["url"].get_text.value
        annotation.description = element.elements["metaDataText"].get_text.value

  
    resources << annotation


  }
  return resources



  end
  
  
 
   
end


#OntrezService.parseNextBio("cell")
