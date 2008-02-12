# Apparently there is a problem with default HTTP dirver that soap4r uses.  In order to circumvent
# you must download and install the lastest version of http-access2 from http://dev.ctor.org/http-access2,
# then set the following option on the object returned from the create_rpc_driver method call:
# options["protocol.http.ssl_config.verify_mode"] = nil
require 'NCBOServiceDriver.rb'
class BioPortalWebservice
  
  
  class << self
    
      #WSDL_URL = "http://ncbo-bioportal1.stanford.edu/ncboservicebeans/NCBOWebserviceBean?wsdl" 
      #WSDL_URL = "http://ncbo-bioportal-stage1.stanford.edu/ncboservicebeans/NCBOWebserviceBean?wsdl" 
      WSDL_URL = "http://www.bioontology.org/ncboservicebeans/NCBOWebserviceBean?wsdl"
      #WSDL_URL = "http://171.65.32.37/ncboservicebeans/NCBOWebserviceBean?wsdl"
      #WSDL_URL = "http://cbioaptst.stanford.edu/ncboservicebeans/NCBOWebserviceBean?wsdl" 
  
      @@soap = NCBOWebserviceEndpoint.new(WSDL_URL)
      #@@soap.wiredump_dev = STDOUT 
     
       def getNode(ontology,node_id)
         results = @@soap.getNode(ontology,node_id)
         for result in results
           node = NodeWrapper.new(result)
           node.ontology_name = ontology
           return  node
         end
         
       end

      def getChildNodes(ontology,node_id,associations)
        nodeList = []
        puts "In GetChildNodes----Ontology: #{ontology}  Node: #{node_id}"
        stringList = nil
        unless associations.nil?
            stringList = StringList.new(1,associations)
        end
        
        
        results = @@soap.getChildNodes(ontology,node_id,stringList)

        for result in results
         if !result.result.nil?
            for associationResultArray in result.result 
              if !associationResultArray.nodeBeanResultArr.nil?
                association = associationResultArray.associationName                
                for remote_node in associationResultArray.nodeBeanResultArr 
                  node = NodeWrapper.new(remote_node)
                  node.ontology_name = ontology     
                  node.parent_association = association
                  nodeList<<node
                end
              end
            end
          end
        end
        return nodeList
      end
      
       def getParentNodes(ontology,node_id,associations)
          nodeList = []
          puts "In GetParentNodes----Ontology: #{ontology}  Node: #{node_id}"
 
          stringList = nil
          unless associations.nil?
            stringList = StringList.new(1,associations)
          end
          
          results = @@soap.getParentNodes(ontology,node_id,stringList)

          for result in results
           if !result.result.nil?
              for associationResultArray in result.result 
                if !associationResultArray.nodeBeanResultArr.nil?
                  for remote_node in associationResultArray.nodeBeanResultArr 
                    node = NodeWrapper.new(remote_node)
                    node.ontology_name = ontology        
                    nodeList<<node
                  end
                end
              end
            end
          end
          return nodeList
        end
      

      def getTopLevelNodes(ontology)
        nodeList = []
        puts "In GetTop----Ontology: #{ontology} "
        
       results = @@soap.getTopLevelNodes(ontology)
       puts "Top level nodes #{results.inspect}"
       
        for result in results          
            for remote_node in result.nodeBeanResultArr
              node = NodeWrapper.new(remote_node)
              node.ontology_name = ontology
              nodeList<<node
            end
        end
        return nodeList
      end

      def getOntologyList
        puts "Getting Ontologies"
        ontologies=[];
       results = @@soap.getNCBOOntologies()
        
        for result in results
          for remote_ontology in  result.result
            ontologies << OntologyWrapper.new(remote_ontology)
          end  
        end
        return ontologies
      end
      
      def getOntology(ontology)
        
        results = @@soap.getNCBOOntology(ontology)
        
        puts results.inspect
        for result in results
          return OntologyWrapper.new(result)
        end
        
      end
      
       def getNodeNameExactMatch(ontologies,search)
        puts "Ontologies: #{ontologies} Term: #{search}"
         
          nodes =[]
          stringList = StringList.new(1,ontologies)
          results = @@soap.getNodeNameExactMatch(stringList,search,true)

          for result in results
            for search_result in  result.result
              label = search_result.ontologyDisplayLabel
                for remote_node in search_result.nodeBeanArr  
                node= NodeWrapper.new(remote_node)
                node.ontology_name = label
                puts node.name
                nodes << node
                end
            end  
          end
          return nodes
       end   
         
       def getNodeNameContains(ontologies,search)
         puts "Ontologies: #{ontologies} Term: #{search}"
         
          nodes =[]
          stringList = StringList.new(1,ontologies)
          results = @@soap.getNodeNameContains(stringList,search,true)

          for result in results
            for search_result in  result.result
              label = search_result.ontologyDisplayLabel
                for remote_node in search_result.nodeBeanArr  
                node= NodeWrapper.new(remote_node)
                node.ontology_name = label
                puts node.name
                nodes << node
                end
            end  
          end
          return nodes
        end
        
         def getNetworkNeighborhoodImage(ontology,node_id,associations=nil)
            stringList = nil
            unless associations.nil?
            stringList = StringList.new(1,associations)
            end
            result = @@soap.getNetworkNeighborhoodImageUrl(ontology,node_id,stringList)
             return "<img src=\"#{result.to_s}\">"
          end
          
          def getPathToRootImage(ontology,node_id,associations=nil)
            stringList = nil
            unless associations.nil?
            stringList = StringList.new(1,associations)
            end
            result = @@soap.getHierarchyToRootImageUrl(ontology,node_id,stringList)
            return "<img src=\"#{result.to_s}\">"
          end
          
          
        
    end



end