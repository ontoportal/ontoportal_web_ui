require 'BioPortalRestfulCore'
class DataAccess
  SERVICE = BioPortalRestfulCore #sets what backend we are using
  
  CACHE_EXPIRE_TIME=60*60
    
    def self.getNode(ontology,node_id)
#      if CACHE.get("#{param(ontology)}::#{node_id}").nil?
        node = SERVICE.getNode(ontology,node_id)  
        #unless  node.kind_of?(Hash) && node[:error]
#        CACHE.set("#{param(ontology)}::#{node_id}",node)
       #end
        return node
#      else
#        return CACHE.get("#{param(ontology)}::#{node_id}")
#      end
    end

    def self.getTopLevelNodes(ontology)
 #     if CACHE.get("#{param(ontology)}::_top").nil?
        topNodes = SERVICE.getTopLevelNodes(ontology)
#        unless topNodes.kind_of?(Hash) && topNodes[:error] 
 #         CACHE.set("#{param(ontology)}::_top",topNodes)
#        end
        return topNodes
#      else
#        return CACHE.get("#{param(ontology)}::_top")
#      end
    end
    
    def self.getOntologyList
      if CACHE.get("ont_list").nil?
        list = SERVICE.getOntologyList
        
        unless list.kind_of?(Hash)  && list[:error] 
          CACHE.set("ont_list",list,CACHE_EXPIRE_TIME)
        end
        
        return list
      else
        return CACHE.get("ont_list")
      end
    end
    
    def self.getActiveOntologies
            if CACHE.get("act_ont_list").nil?
              list = SERVICE.getOntologyList
              unless list.kind_of?(Hash) && list[:error]
              
              activeOntologies = []
              for item in list
                if item.statusId.to_i.eql?(3)
                  activeOntologies << item
                end
              end
              CACHE.set("act_ont_list",activeOntologies,CACHE_EXPIRE_TIME)
              list = activeOntologies
              end
              return list
            else
              return CACHE.get("act_ont_list")
            end
      
    end

       def self.getOntologyVersions(ontology)
         if CACHE.get("#{ontology}::_versions").nil?
           details = SERVICE.getOntologyVersions(ontology)
           unless details.kind_of?(Hash) && details[:error]
             CACHE.set("#{ontology}::_versions",details,CACHE_EXPIRE_TIME)
           end
           return details
         else
           return CACHE.get("#{ontology}::_versions")
         end
       end

    
    def self.getOntology(ontology)
      if CACHE.get("#{ontology}::_details").nil?
        details = SERVICE.getOntology(ontology)
        unless details.kind_of?(Hash) && details[:error]
          CACHE.set("#{ontology}::_details",details,CACHE_EXPIRE_TIME)
        end        
        return details
      else
        return CACHE.get("#{ontology}::_details")
      end
    end
    
    def self.getLatestOntology(ontology)
      details = SERVICE.getLatestOntology(ontology)
      return details
    end
    
    def self.getNodeNameSoundsLike(ontologies,search)
      if CACHE.get("#{param(ontologies.join("|"))}::_searchsound::#{param(search)}").nil?
        results = SERVICE.getNodeNameContains(ontologies,search)
        unless results.kind_of?(Hash) && results[:error]
          CACHE.set("#{param(ontologies.join("|"))}::_searchsound::#{param(search)}",results)
        end
        return results
      else
        return CACHE.get("#{param(ontologies.join("|"))}::_searchsound::#{param(search)}")
      end
    end
    
    def self.getNodeNameContains(ontologies,search)      
      if CACHE.get("#{param(ontologies.join("|"))}::_search::#{param(search)}").nil?
        results = SERVICE.getNodeNameContains(ontologies,search)
        unless results.kind_of?(Hash) && results[:error]
          CACHE.set("#{param(ontologies.join("|"))}::_search::#{param(search)}",results)
        end
        return results
      else
        return CACHE.get("#{param(ontologies.join("|"))}::_search::#{param(search)}")
      end
    end
    
    def self.getUsers
      if CACHE.get("user_list").nil?
          results = SERVICE.getUsers  
          unless results.kind_of?(Hash) && results[:error]
            CACHE.set("user_list",results)
          end        
          return results
      else
        return CACHE.get("user_list")
      end
    end
    
    def self.getUserByEmail(email)
      found_user = nil
       users =self.getUsers
       for user in users
         if user.email.eql?(email)
            found_user = user
         end
       end
       return found_user              
    end
    
    
     def self.getUser(user_id)
       if CACHE.get("user::#{user_id}").nil?
         puts "not getting user #{user_id} from cache"
            results = SERVICE.getUser(user_id)
            puts results.inspect
            unless results.kind_of?(Hash) && results[:error]
              CACHE.set("user::#{user_id}",results)
            end        
       
            return results
        else
          puts "Getting user #{user_id} from cache"
          return CACHE.get("user::#{user_id}")
        end
      end
    
    def self.authenticateUser(username,password)    
      user = SERVICE.authenticateUser(username,password)
      return user
    end
      
    def self.createUser(params)    
      user = SERVICE.createUser(params)
      CACHE.delete("user_list")
      return user
    end
    
     def self.updateUser(params,id)
      user = SERVICE.updateUser(params,id)
      CACHE.delete("user_list")
      CACHE.delete("user::#{id}")
      return user
    end
    
    def self.createOntology(params)
      ontology = SERVICE.createOntology(params)
      CACHE.delete("act_ont_list")
      CACHE.delete("ont_list")
        unless(params[:ontologyId].nil?)
          CACHE.delete("#{params[:ontologyId]}::_versions")
        end
      return ontology
    end
    
    def self.updateOntology(params)
      ontology = SERVICE.updateOntology(params)
      CACHE.delete("#{params[:id]}::_details")
      return ontology
    end
    
    def self.download(id)
      return SERVICE.download(id)
    end
    
    
    
    
    def self.getAttributeValueContains(ontologies,search)
       if CACHE.get("#{param(ontologies.join("|"))}::_searchAttrCont::#{param(search)}").nil?
        results = SERVICE.getAttributeValueContains(ontologies,search)
        CACHE.set("#{param(ontologies.join("|"))}::_searchAttrCont::#{param(search)}",results)
        return results
      else
        return CACHE.get("#{param(ontologies.join("|"))}::_searchAttrCont::#{param(search)}")
      end
      
      
    end
    
    def self.getAttributeValueSoundsLike(ontologies,search)
       if CACHE.get("#{param(ontologies.join("|"))}::_searchAttrSound::#{param(search)}").nil?
        results = SERVICE.getAttributeValueSoundsLike(ontologies,search)
        CACHE.set("#{param(ontologies.join("|"))}::_searchAttrSound::#{param(search)}",results)
        return results
      else
        return CACHE.get("#{param(ontologies.join("|"))}::_searchAttrSound::#{param(search)}")
      end
      
      
    end
    
    
    
    
#    def self.getNetworkNeighborhoodImage(ontology,node_id,associations=nil)
#      if CACHE.get("#{param(ontology)}::#{node_id}_nnImage::#{associations}").nil?
#        image = SERVICE.getNetworkNeighborhoodImage(ontology,node_id,associations) 
#        CACHE.set("#{param(ontology)}::#{node_id}_nnImage::#{associations}",image)
#        return image
#      else
#        return CACHE.get("#{param(ontology)}::#{node_id}_nnImage::#{associations}")
#      end
#    end
    
#    def self.getPathToRootImage(ontology,node_id,associations=nil)
#      if CACHE.get("#{param(ontology)}::#{node_id}_ptrImage::#{associations}").nil?
#        image = SERVICE.getPathToRootImage(ontology,node_id,associations) 
#        CACHE.set("#{param(ontology)}::#{node_id}_ptrImage::#{associations}",image)
#        return image
#      else
#        return CACHE.get("#{param(ontology)}::#{node_id}_ptrImage::#{associations}")
#      end
#    end
    
    def self.getPathToRoot(ontology,source)      
      return SERVICE.getPathToRoot(ontology,source)
    end
    
    def self.param(string)
      return string.gsub(" ","_")
    end
   
  
end