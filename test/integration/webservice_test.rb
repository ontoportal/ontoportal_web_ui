# Apparently there is a problem with default HTTP dirver that soap4r uses.  In order to circumvent
# you must download and install the lastest version of http-access2 from http://dev.ctor.org/http-access2,
# then set the following option on the object returned from the create_rpc_driver method call:
# options["protocol.http.ssl_config.verify_mode"] = nil


require 'rubygems'
gem 'soap4r'
require 'soap/rpc/driver'
require 'soap/wsdlDriver'


  
    WSDL_URL = "http://www.bioontology.org/ncboservicebeans/NCBOWebserviceBean?wsdl"
    #WSDL_URL = "http://171.65.32.38/ncboservicebeans/NCBOWebserviceBean?wsdl"
 

    soap = SOAP::WSDLDriverFactory.new( WSDL_URL ).create_rpc_driver
    
    StringList = Struct.new(:dummyForJbossBug,:stringArr)
    stringlist = StringList.new()
    stringlist.dummyForJbossBug=1
    array =[]
    array<< "is_a"
    stringlist.stringArr =array 
    
    results = soap.getNetworkNeighborhoodImageUrl("Xenopus anatomy and development","XAO:0000039",stringlist)
 
    for result in results
      
        puts result
          
    end
      
      
      
      
    def getNode(ontology,node_id)
      results = soap.getNetworkNeighborhoodImageUrl(ontology,node_id,input)
      
      for result in results
        puts result.name
      end
    end
    
    def getChildNodes(ontology,node_id,relationship)

      results = soap.getChildNodes(ontology,node_id,relationship||nil)

      for result in results
        puts "1 #{result}"
        for node in result.result.nodeBeanResultArr
          puts node.name
          puts node.id
        end


      end



      
    end
    
    
    
    def getTopLevelNodes(ontology)
    

      results = soap.getTopLevelNodes(ontology)

      for result in results
        for node in  result.nodeBeanResultArr
            puts node.name
        end
      end
    end
    
    def getOntologyList
      
      results = soap.getNCBOOntologies()

      puts "OntologyList"
      
      
      for result in results
      puts result
        for ontology in result.result
          puts ontology.displayLabel
        end
      end
    end
    
    
 


