require "rexml/document"
require 'open-uri'
class BioPortalRestfulCore
  
  #Resources
#    BASE_URL="http://ncbo-core-dev1:8080/bioportal/rest"
    #BASE_URL="http://ncbo-core-load1.stanford.edu:8080/bioportal/rest"
    #BASE_URL="http://ncbo-core-prod1.stanford.edu:8080/bioportal/rest"
    BASE_URL="http://ncbo-core-stage1.stanford.edu:8080/bioportal/rest"
    
    ONTOLOGIES_PATH = "/ontologies/%ONT%"
    CONCEPT_PATH ="/concepts/%ONT%/%CONC%"
    PATH_PATH = "/path/%ONT%/%CONC%/root"
    VERSIONS_PATH="/ontologies/versions/%ONT%"
    SEARCH_PATH="/search/concepts/%query%?ontologies=%ONT%"
    PROPERTY_SEARCH_PATH="/search/properties/%query%?ontologies=%ONT%"
    VIRTUAL_URI_PATH="/virtual/%ONT%/%CONC%"
    META_SEARCH_PATH="/search/meta/%query%"
    USERS_PATH="/users"
    USER_PATH = "/users/%USR%"
    AUTH_PATH = "/auth"
    PARSE_ONTOLOGY = "/ontologies/parse/%ONT%"
    PARSE_BATCH = "/ontologies/parsebatch/%START%/%END%"
    
    
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
         
         puts "Requesting : #{BASE_URL+CONCEPT_PATH.gsub("%ONT%",ontology.to_s).gsub("%CONC%",node_id)}"
          begin
         doc = REXML::Document.new(open(BASE_URL+CONCEPT_PATH.gsub("%ONT%",ontology.to_s).gsub("%CONC%",node_id)))
          rescue
          end
         node = errorCheck(doc)
         
         unless node.nil?
           return node
         end
         
         
         time = Time.now
#          puts "#########Full Doc############"
#          puts doc.to_s
#          puts "#####################"
          doc.elements.each("*/data/classbean"){ |element|  
          node = parseConcept(element,ontology)
         }
#         puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#         puts node.inspect
#         puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
         puts "getNode Parse Time: #{Time.now-time}"
         return node
       end
      

      def self.getTopLevelNodes(ontology)
        node = nil
         doc = REXML::Document.new(open(BASE_URL+CONCEPT_PATH.gsub("%ONT%",ontology.to_s).gsub("%CONC%","root")))
         time = Time.now
         node = errorCheck(doc)         
         unless node.nil?
           return node
         end
         
                   puts "I should be Nil: #{node}"
         
          doc.elements.each("*/data/classbean"){ |element|  
          node = parseConcept(element,ontology)
         }
         puts "getTopLevelNodes Parse Time: #{Time.now-time}"
        return node.children
      end

      def self.getOntologyList
        ontologies=nil
         doc = REXML::Document.new(open(BASE_URL+ONTOLOGIES_PATH.gsub("%ONT%","")))
         
         ontologies = errorCheck(doc)
         
         unless ontologies.nil?
           return ontologies
         end

         ontologies = []
         time = Time.now
          doc.elements.each("*/data/list/ontology"){ |element| 
          ontologies << parseOntology(element)
         }
         puts "getOntologyList Parse Time: #{Time.now-time}"
        return ontologies
      end
      
      def self.getOntologyVersions(ontology)

         doc = REXML::Document.new(open(BASE_URL+VERSIONS_PATH.gsub("%ONT%",ontology.to_s)))
        
         ontologies = errorCheck(doc)

         unless ontologies.nil?
           return ontologies
         end

        ontologies=[]

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
        begin
          doc = REXML::Document.new(open(BASE_URL + ONTOLOGIES_PATH.gsub("%ONT%",ontology.to_s)))
        rescue Exception=>e
          doc =  REXML::Document.new(e.io.read)
          puts doc.inspect
        end
            ont = errorCheck(doc)

             unless ont.nil?
               return ont
             end
          puts "I should be Nil: #{ont}"
          
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
      
      def self.parseOntology(ontology)
          ont = nil
          puts "Ontology: #{ontology}"
            doc = REXML::Document.new(open(BASE_URL + PARSE_ONTOLOGY.gsub("%ONT%",ontology.to_s)))
            
                 ont = errorCheck(doc)

                   unless ont.nil?
                     return ont
                   end
            
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
      def self.getLatestOntology(ontology)
         ont = nil
          puts "Ontology: #{ontology}"
          puts BASE_URL + VIRTUAL_URI_PATH.gsub("%ONT%",ontology.to_s).gsub("%CONC%","")
            doc = REXML::Document.new(open(BASE_URL + VIRTUAL_URI_PATH.gsub("%ONT%",ontology.to_s).gsub("%CONC%","")))
            
              ont = errorCheck(doc)

                 unless ont.nil?
                   return ont
                 end
            
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
           doc = REXML::Document.new(open(BASE_URL+PATH_PATH.gsub("%ONT%",ontology.to_s).gsub("%CONC%",source)+"?light=false"))
           
             root = errorCheck(doc)

                unless root.nil?
                  return root
                end
           
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
        begin
            doc = REXML::Document.new(open(BASE_URL+SEARCH_PATH.gsub("%ONT%",ontologies.join(",")).gsub("%query%",search.gsub(" ","%20"))))
           rescue Exception=>e
              #doc =  REXML::Document.new(e.io.read)
              puts doc.to_s
            end   
               results = errorCheck(doc)

                  unless results.nil?
                    return results
                  end 
          results = []
            
            time = Time.now
             doc.elements.each("*/data/list/searchresultbean"){ |element|  
             results << parseSearchResults(element)
            }
          puts "getNodeNameContains Parse Time: #{Time.now-time}"
          return results
        end
        
        def self.getUsers

          doc = REXML::Document.new(open(BASE_URL+USERS_PATH))
          
               results = errorCheck(doc)

                  unless results.nil?
                    return results
                  end
          results = []          
          time = Time.now
           doc.elements.each("*/data/list/user"){ |element|  
           results << parseUser(element)
          }
        puts "getUsers Parse Time: #{Time.now-time}"
        return results
          
        end
        
        def self.getUser(user_id)
          user=nil
          doc = REXML::Document.new(open(BASE_URL+USER_PATH.gsub("%USR%",user_id.to_s)))
          
                  user = errorCheck(doc)

                      unless user.nil?
                        return user
                      end
          
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
          rescue Exception=>e
            doc =  REXML::Document.new(e.io.read)
            puts doc.to_s
          end
             user = errorCheck(doc)

                  unless user.nil?
                    return user
                  end
          
          time = Time.now
           doc.elements.each("*/data/user"){ |element|  
           user = parseUser(element)
           user.session_id = doc.elements["success"].elements["sessionId"].get_text.value
           
          }
           puts "authenticateUser Parse Time: #{Time.now-time}"   
          
          
                    
        return user
        end
        
        def self.createUser(params)
          user = nil
            begin
            doc = REXML::Document.new(postToRestlet(BASE_URL+USERS_PATH.gsub("%USR%","")+"?&applicationid=#{APPLICATION_ID}",params))
            rescue Exception=>e
              doc =  REXML::Document.new(e.io.read)
              puts doc.to_s
            end
               user = errorCheck(doc)

                    unless user.nil?
                      return user
                    end
            
            time = Time.now
             doc.elements.each("*/data/user"){ |element|  
             user = parseUser(element)
            }
             puts "createUser Parse Time: #{Time.now-time}"   


          return user
        end
        
        
        
        
        def self.updateUser(params,id)
          user = nil
          begin
          doc = REXML::Document.new(putToRestlet(BASE_URL+USER_PATH.gsub("%USR%",id.to_s)+"?&applicationid=#{APPLICATION_ID}",params))
          rescue Exception=>e
            puts e.message
            puts e.backtrace
            doc =  REXML::Document.new(e.io.read)
            puts doc.to_s
          end
             user = errorCheck(doc)

                  unless user.nil?
                    return user
                  end
          
            time = Time.now
            doc.elements.each("*/data/user"){ |element|  
            user = parseUser(element)
          }
          puts "updateUser Parse Time: #{Time.now-time}"   


          return user
        end  
        
        
        def self.createOntology(params)
            ontology = nil
              begin
              doc = REXML::Document.new(postMultiPart(BASE_URL+ONTOLOGIES_PATH.gsub("%ONT%","")+"?&applicationid=#{APPLICATION_ID}",params))
              rescue Exception=>e
                doc =  REXML::Document.new(e.io.read)
                puts doc.to_s
              end
                 ontology = errorCheck(doc)

                      unless ontology.nil?
                        return ontology
                      end
              
              time = Time.now
               doc.elements.each("*/data/ontology"){ |element|  
               ontology = parseOntology(element)
              }
               puts "createOntology Parse Time: #{Time.now-time}"   


            return ontology
          end
        
        def self.updateOntology(params)
          puts "UPdating Ontology#############"
                  ontology = nil
                    begin
                    doc = REXML::Document.new(putToRestlet(BASE_URL+ONTOLOGIES_PATH.gsub("%ONT%","")+"?&applicationid=#{APPLICATION_ID}",params))
                    rescue Exception=>e
                       doc =  REXML::Document.new(e.io.read)
                       puts doc.to_s
                     end
                    
                         ontology = errorCheck(doc)

                              unless ontology.nil?
                                return ontology
                              end
                    puts doc.to_s
                    time = Time.now
                     doc.elements.each("*/data/ontology"){ |element|  
                     ontology = parseOntology(element)
                    }
                     puts "updateOntology Parse Time: #{Time.now-time}"   
                   
                  return ontology          
          
        end
        
        def self.download(id)          
          return BASE_URL+"/ontologies/download/#{id}"
        end
              
        
        def getNodeNameSoundsLike(ontologies,search)
        
        end
        
                
        def self.getAttributeValueContains(ontologies,search)

              doc = REXML::Document.new(open(BASE_URL+PROPERTY_SEARCH_PATH.gsub("%ONT%",ontologies.join(",")).gsub("%query%",search.gsub(" ","%20"))))
                   results = errorCheck(doc)

                        unless results.nil?
                          return results
                        end
            results = []              
              time = Time.now
               doc.elements.each("*/data/list/searchresultbean"){ |element|  
               results << parseSearchResults(element)
              }
            puts "getNodeNameContains Parse Time: #{Time.now-time}"
            return results
       end
       
        def getAttributeValueSoundsLike(ontologies,search)
        
        end
       
        
    
          


private


  def self.postMultiPart(url,paramsHash)
    params=[]
      for param in paramsHash.keys
        if param.eql?("filePath")
          params << file_to_multipart('filePath',paramsHash["filePath"].original_filename,paramsHash["filePath"].content_type,paramsHash["filePath"])
        else
           params << text_to_multipart(param,paramsHash[param])
        end
          
      end

    boundary = '349832898984244898448024464570528145'
    query = 
      params.collect {|p| '--' + boundary + "\r\n" + p}.join('') + "--" + boundary + "--\r\n"
    uri = URI.parse(url)
#    puts "==========="
#    puts query
#    puts "=========== "
    response = Net::HTTP.new(uri.host,"8080").start.
      post2(uri.path,
            query,
            "Content-type" => "multipart/form-data; boundary=" + boundary)
    puts response.inspect
    puts response.body
    return response.body
    
  end

  def self.text_to_multipart(key,value)
     return "Content-Disposition: form-data; name=\"#{CGI::escape(key)}\"\r\n" + 
            "\r\n" + 
            "#{value}\r\n"
  end

   def self.file_to_multipart(key,filename,mime_type,content)
     return "Content-Disposition: form-data; name=\"#{CGI::escape(key)}\"; filename=\"#{filename}\"\r\n" +
            "Content-Transfer-Encoding: base64\r\n" +
            "Content-Type: text/plain\r\n" + 
            "\r\n" + 
            content.read() + "\r\n"
   end


  def self.postToRestlet(url,paramsHash)
    res = Net::HTTP.post_form(URI.parse(url),paramsHash)
    puts res.body
    return res.body
  end

  def self.putToRestlet(url,paramsHash)
    puts paramsHash.inspect
    paramsHash["method"]="PUT"
    puts paramsHash.inspect
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
    
#    puts "Results Hash"
#    puts "----------------"
#    puts resultHash.inspect
#    puts "-----------------"
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
    ontology.displayLabel= ontologybeanXML.elements["displayLabel"].get_text.value 
    ontology.ontologyId = ontologybeanXML.elements["ontologyId"].get_text.value
    ontology.userId = ontologybeanXML.elements["userId"].get_text.value rescue ""
    ontology.parentId = ontologybeanXML.elements["parentId"].get_text.value rescue ""
    ontology.format = ontologybeanXML.elements["format"].get_text.value rescue  ""
    ontology.versionNumber = ontologybeanXML.elements["versionNumber"].get_text.value rescue   ""
    ontology.internalVersion = ontologybeanXML.elements["internalVersionNumber"].get_text.value
    ontology.versionStatus = ontologybeanXML.elements["versionStatus"].get_text.value rescue   ""
    ontology.isCurrent = ontologybeanXML.elements["isCurrent"].get_text.value rescue   ""
    ontology.isRemote = ontologybeanXML.elements["isRemote"].get_text.value rescue   ""
    ontology.isReviewed = ontologybeanXML.elements["isReviewed"].get_text.value rescue   ""
    ontology.statusId = ontologybeanXML.elements["statusId"].get_text.value rescue   ""
    ontology.dateReleased =  Date.parse(ontologybeanXML.elements["dateReleased"].get_text.value).strftime('%m/%d/%Y') rescue   ""
    ontology.contactName = ontologybeanXML.elements["contactName"].get_text.value rescue   ""
    ontology.contactEmail = ontologybeanXML.elements["contactEmail"].get_text.value rescue   ""
    ontology.urn = ontologybeanXML.elements["urn"].get_text.value rescue    ""
    ontology.isFoundry = ontologybeanXML.elements["isFoundry"].get_text.value rescue   ""
    ontology.isManual = ontologybeanXML.elements["isManual"].get_text.value rescue   ""
    ontology.filePath = ontologybeanXML.elements["filePath"].get_text.value rescue   ""
    ontology.homepage = ontologybeanXML.elements["homepage"].get_text.value rescue   ""
    ontology.documentation = ontologybeanXML.elements["documentation"].get_text.value rescue   ""
    ontology.publication = ontologybeanXML.elements["publication"].get_text.value rescue   ""
    ontology.dateCreated = Date.parse(ontologybeanXML.elements["dateCreated"].get_text.value).strftime('%m/%d/%Y') rescue ""
     
    return ontology
    
  end

  def self.errorCheck(doc)
    response=nil
    errorHolder={}
    begin
    doc.elements.each("org.ncbo.stanford.bean.response.ErrorStatusBean"){ |element|  
      
     errorHolder[:error]=true
     errorHolder[:shortMessage]= element.elements["shortMessage"].get_text.value
     errorHolder[:longMessage]=element.elements["longMessage"].get_text.value
     response=errorHolder
    }
    rescue
      end
    puts "##########Error Check###########"
    puts doc.to_s
    puts "Error Check is Returning #{response.nil?}"
    puts "#####################"
    return response
  end

  def self.parseConcept(classbeanXML,ontology)
    puts "----------------Parsing Piece-------------"
    puts classbeanXML
    puts "------------------------------------------"

       node = NodeWrapper.new
       node.child_size=0
         node.id = classbeanXML.elements["id"].get_text.value
         node.name = classbeanXML.elements["label"].get_text.value rescue node.id
         node.version_id = ontology
         node.children =[]
         node.properties ={}
         classbeanXML.elements["relations"].elements.each("entry"){ |entry|
#           puts "##########Element###########"
#            puts entry.to_s

             case entry.elements["string"].get_text.value
               when SUBCLASS
                if entry.elements["list"].attributes["reference"]
                   entry.elements["list"].elements.each(entry.elements["list"].attributes["reference"]){|element|
                     element.elements.each{|classbean|
                        puts "------------Reference Item in list----------"
                         puts classbean.to_s
                         puts "--------------------------------"
                         #issue with using reference.. for some reason pulls in extra guys sometimes
                         puts classbean.name
                         if classbean.name.eql?("classbean")
                           node.children<<parseConcept(classbean,ontology)
                         end
                         }
                     }
                   
                else
                  entry.elements["list"].elements.each {|element|
#                    puts "------------item in list----------"
#                      puts element.to_s
#                      puts "--------------------------------"
                      node.children<<parseConcept(element,ontology)
                  } 
                end                
               when SUPERCLASS
              
               when CHILDCOUNT
                 node.child_size = entry.elements["int"].get_text.value.to_i
               else                                  
                 node.properties[entry.elements["string"].get_text.value] = entry.elements["list"].elements.map{|element| 
                   if(element.name.eql?("classbean"))
                      parseConcept(element,ontology).name 
                  else 
                    element.get_text.value unless element.get_text.value.empty? 
                  end}.join(" , ") #rescue ""
               end
 #           puts "#####################"
        }
        return node
  end

end
  