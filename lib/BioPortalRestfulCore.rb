require "rexml/document"
require 'open-uri'
class BioPortalRestfulCore
  
  #Resources
    BASE_URL="http://ncbo-core-dev1:8080/bioportal/rest"
    ONTOLOGIES_PATH = "/ontologies/%ONT%"
    CONCEPT_PATH ="/concepts/%ONT%/%CONC%"
    PATH_PATH = "/path/%ONT%/%CONC%/root"
    VERSIONS_PATH="/ontologies/versions/%ONT%"
    SEARCH_PATH="/search/concepts/%query%?ontologies=%ONT%"
    META_SEARCH_PATH="/search/meta/%query%"
    USERS_PATH = "/users/%USR%"
    AUTH_PATH = "/auth"
  #Constants
    SUPERCLASS="SuperClass"
    SUBCLASS="SubClass"
    CHILDCOUNT="ChildCount"
    APPLICATION_ID = "4ea81d74-8960-4525-810b-fa1baab576ff"
    
 
#    OBO
#    2861
#    20845
#    3231
#    2991
#    2996

#    OWL
#    3905
#    13386
#    6723
#    3205
#    4525
 

       def self.getNode(ontology,node_id)
         node = nil
         doc = REXML::Document.new(open(BASE_URL+CONCEPT_PATH.gsub("%ONT%",ontology).gsub("%CONC%",node_id)))
         time = Time.now
          doc.elements.each("*/data/classbean"){ |element|  
          node = parseConcept(element,ontology)
         }
         puts "getNode Parse Time: #{Time.now-time}"
         return node
       end

      def self.getChildNodes(ontology,node_id,associations)
        nodeList = []
       
        return nodeList
      end
      
       def self.getParentNodes(ontology,node_id,associations)
          nodeList = []
         
          return nodeList
        end
      

      def self.getTopLevelNodes(ontology)
        node = nil
         doc = REXML::Document.new(open(BASE_URL+CONCEPT_PATH.gsub("%ONT%",ontology).gsub("%CONC%","root")))
         time = Time.now
          doc.elements.each("*/data/classbean"){ |element|  
          node = parseConcept(element,ontology)
         }
         puts "getTopLevelNodes Parse Time: #{Time.now-time}"
        return node.children
      end

      def self.getOntologyList
        ontologies=[];
         doc = REXML::Document.new(open(BASE_URL+ONTOLOGIES_PATH.gsub("%ONT%","")))
         time = Time.now
          doc.elements.each("*/data/list/ontology"){ |element|  
          ontologies << parseOntology(element)
         }
         puts "getOntologyList Parse Time: #{Time.now-time}"
        return ontologies
      end
      
      def self.getOntologyVersions(ontology)
        ontologies=[];
         doc = REXML::Document.new(open(BASE_URL+VERSIONS_PATH.gsub("%ONT%",ontology)))
         time = Time.now
          doc.elements.each("*/data/list/ontology"){ |element|  
          ontologies << parseOntology(element)
         }
         puts "getOntologyVersions Parse Time: #{Time.now-time}"
        return ontologies
      end
      
      
      
      def self.getOntology(ontology)
        ont = nil
        puts "Ontology: #{ontology}"
          doc = REXML::Document.new(open(BASE_URL + ONTOLOGIES_PATH.gsub("%ONT%",ontology)))
         time = Time.now
            doc.elements.each("*/data/ontology"){ |element|  
            ont = parseOntology(element)
          }                    
         puts "getOntology Parse Time: #{Time.now-time}"
         
      #  if versions
       #   doc = REXML::Document.new(open(BASE_URL+ONTOLOGY_PATH.gsub("%ONT%",ontology)))
      #  end
        return ont
      end
      
      def self.getPathToRoot(ontology,source,light=nil)
           root = nil
           doc = REXML::Document.new(open(BASE_URL+PATH_PATH.gsub("%ONT%",ontology).gsub("%CONC%",source)+"?light=false"))
           time = Time.now
            doc.elements.each("*/data/classbean"){ |element|  
            root = parseConcept(element,ontology)
           }
         puts "getPathToRoot Parse Time: #{Time.now-time}"
           return root
        
      end
      
       def getNodeNameExactMatch(ontologies,search)

        
       end   
         
       def self.getNodeNameContains(ontologies,search)
          results = []
            doc = REXML::Document.new(open(BASE_URL+SEARCH_PATH.gsub("%ONT%",ontologies.join(",")).gsub("%query%",search)))
            time = Time.now
             doc.elements.each("*/data/list/searchresultbean"){ |element|  
             results << parseSearchResults(element)
            }
          puts "getNodeNameContains Parse Time: #{Time.now-time}"
          return results
        end
        
        def self.getUsers
          results = []
          doc = REXML::Document.new(open(BASE_URL+USERS_PATH.gsub("%USR%","")))
          time = Time.now
           doc.elements.each("*/data/list/user"){ |element|  
           results << parseUser(element)
          }
        puts "getUsers Parse Time: #{Time.now-time}"
        return results
          
        end
        
        def self.getUser(user_id)
          user=nil
          doc = REXML::Document.new(open(BASE_URL+USERS_PATH.gsub("%USR%",user_id)))
          time = Time.now
           doc.elements.each("*/data/user"){ |element|  
           user = parseUser(element)
          }
        puts "getUsers Parse Time: #{Time.now-time}"
        return user
        end

        def self.authenticateUser(username,password)
          user=nil
          puts BASE_URL+AUTH_PATH+"?username=#{username}&password=#{password}&applicationid=#{APPLICATION_ID}"
          begin
          doc = REXML::Document.new(open(BASE_URL+AUTH_PATH+"?username=#{username}&password=#{password}&applicationid=#{APPLICATION_ID}"))
          time = Time.now
           doc.elements.each("*/data/user"){ |element|  
           user = parseUser(element)
           user.session_id = doc.elements["success"].elements["sessionID"].get_text.value
           
          }
           puts "authenticateUser Parse Time: #{Time.now-time}"   
          rescue 
            puts "User Is Invalid"
          end
                    
        return user
        end
        
        def self.createUser(params)
          user = nil
#            begin
            doc = REXML::Document.new(postToRestlet(BASE_URL+USERS_PATH.gsub("%USR%","")+"?&applicationid=#{APPLICATION_ID}",params))
            time = Time.now
             doc.elements.each("*/data/user"){ |element|  
             user = parseUser(element)
            }
             puts "createUser Parse Time: #{Time.now-time}"   
#            rescue 
#              puts "User Is Invalid"
#            end

          return user
        end
        
        def self.updateUser(params)
          user = nil
        #            begin
          doc = REXML::Document.new(postToRestlet(BASE_URL+USERS_PATH.gsub("%USR%","")+"?&applicationid=#{APPLICATION_ID}",params))
            time = Time.now
            doc.elements.each("*/data/user"){ |element|  
            user = parseUser(element)
          }
          puts "createUser Parse Time: #{Time.now-time}"   
        #            rescue 
        #              puts "User Is Invalid"
        #            end

          return user
        end        
        
        def getNodeNameSoundsLike(ontologies,search)
        
        end
        
                
        def getAttributeValueContains(ontologies,search)
        
       end
       
        def getAttributeValueSoundsLike(ontologies,search)
        
        end
       
        
         def getNetworkNeighborhoodImage(ontology,node_id,associations=nil)
          
        end
          


private


  def self.postToRestlet(url,paramsHash)
    res = Net::HTTP.post_form(URI.parse(url),paramsHash)
    puts res.body
    return res.body
  end

  def self.putToRestlet(url,paramsHash)
    paramsHash[:method]="PUT"
    res = Net::HTTP.post_form(URI.parse(url),paramsHash)
     puts res.body
     return res.body
  end

  def self.parseSearchResults(searchResultBean)
    resultHash={}
    
    resultHash[:version_id]= searchResultBean.elements["ontologyVersionId"].get_text.value
    resultHash[:names] = []
    searchResultBean.elements["names"].elements.each {|element|       
        resultHash[:names]<<parseConcept(element,resultHash[:version_id])
    }
    
    resultHash[:properties] = []
    searchResultBean.elements["properties"].elements.each {|element|       
        resultHash[:properties]<<parseConcept(element,resultHash[:version_id])
    }
    
    resultHash[:metadata] = []
    searchResultBean.elements["metadata"].elements.each {|element|       
        resultHash[:metadata]<<parseConcept(element,resultHash[:version_id])
    }
    
    puts "Results Hash"
    puts "----------------"
    puts resultHash.inspect
    puts "-----------------"
    return resultHash
    
    
    
  end

  def self.parseUser(userbeanXML)
    user = UserWrapper.new
    
    user.id=userbeanXML.elements["id"].get_text.value
    user.username=userbeanXML.elements["username"].get_text.value
    user.email=userbeanXML.elements["email"].get_text.value
    user.firstname=userbeanXML.elements["firstname"].get_text.value rescue ""
    user.lastname=userbeanXML.elements["lastname"].get_text.value rescue ""
    user.phone=userbeanXML.elements["id"].get_text.value rescue ""
    
    roles = []   
    begin
    userbeanXML.elements["roles"].elements.each("string"){ |role|
     roles << role.get_text.value
    } 
    rescue
    end
    user.roles=roles
    
    return user
  end

  def self.parseOntology(ontologybeanXML)

    ontology = OntologyWrapper.new
    ontology.id = ontologybeanXML.elements["id"].get_text.value
    ontology.display_label= ontologybeanXML.elements["displayLabel"].get_text.value
    ontology.ontology_id = ontologybeanXML.elements["ontologyId"].get_text.value
    ontology.user_id = ontologybeanXML.elements["userId"].get_text.value
    ontology.parent_id = ontologybeanXML.elements["parentId"].get_text.value
    ontology.format = ontologybeanXML.elements["format"].get_text.value rescue  ""
    ontology.version_number = ontologybeanXML.elements["versionNumber"].get_text.value rescue   ""
    ontology.internal_version = ontologybeanXML.elements["internalVersionNumber"].get_text.value
    ontology.version_status = ontologybeanXML.elements["versionStatus"].get_text.value rescue   ""
    ontology.is_current = ontologybeanXML.elements["isCurrent"].get_text.value rescue   ""
    ontology.is_remote = ontologybeanXML.elements["isRemote"].get_text.value rescue   ""
    ontology.is_reviewed = ontologybeanXML.elements["isReviewed"].get_text.value rescue   ""
    ontology.status_id = ontologybeanXML.elements["statusId"].get_text.value rescue   ""
    ontology.date_released = ontologybeanXML.elements["dateReleased"].get_text.value rescue   ""
    ontology.contact_name = ontologybeanXML.elements["contactName"].get_text.value rescue   ""
    ontology.contact_email = ontologybeanXML.elements["contactEmail"].get_text.value rescue   ""
    ontology.urn = ontologybeanXML.elements["urn"].get_text.value rescue    ""
    ontology.is_foundry = ontologybeanXML.elements["isFoundry"].get_text.value rescue   ""
    ontology.file_path = ontologybeanXML.elements["filePath"].get_text.value rescue   ""
    ontology.homepage = ontologybeanXML.elements["homepage"].get_text.value rescue   ""
    ontology.documentation = ontologybeanXML.elements["documentation"].get_text.value rescue   ""
    ontology.publication = ontologybeanXML.elements["publication"].get_text.value rescue   ""
    return ontology
    
  end

  def self.parseConcept(classbeanXML,ontology)


       node = NodeWrapper.new
       node.child_size=0
         node.id = classbeanXML.elements["id"].get_text.value
         node.name = classbeanXML.elements["label"].get_text.value
         node.ontology_id = ontology
         node.children =[]
         node.properties ={}
         classbeanXML.elements["relations"].elements.each("entry"){ |entry|
         
             case entry.elements["string"].get_text.value
               when SUBCLASS  
                  entry.elements["list"].elements.each {|element|
                     
                      node.children<<parseConcept(element,ontology)
                  }                 
               when SUPERCLASS
              
               when CHILDCOUNT
                 node.child_size = entry.elements["int"].get_text.value.to_i
               else
                 
                 
                 node.properties[entry.elements["string"].get_text.value] = entry.elements["list"].elements.map{|element| element.get_text.value}.flatten
               end

        }
        return node
  end

end