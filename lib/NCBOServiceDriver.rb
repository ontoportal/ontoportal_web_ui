
require 'NCBOService.rb'
require 'NCBOServiceMappingRegistry.rb'
require 'soap/rpc/driver'

class NCBOWebserviceEndpoint < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://cbioapprd.Stanford.EDU:8080/ncboservicebeans/NCBOWebserviceBean"
  NsBeans = "http://org.ncbo.stanford.server/beans"

  Methods = [
    [ XSD::QName.new(NsBeans, "getAssociationsForOntology"),
      "",
      "getAssociationsForOntology",
      [ ["in", "String_1", ["::SOAP::SOAPString"]],
        ["retval", "result", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getAttributeValueContains"),
      "",
      "getAttributeValueContains",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "StringList_2", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getAttributeValueEndsWith"),
      "",
      "getAttributeValueEndsWith",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "StringList_2", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getAttributeValueSoundsLike"),
      "",
      "getAttributeValueSoundsLike",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "StringList_2", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getAttributeValueStartsWith"),
      "",
      "getAttributeValueStartsWith",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "StringList_2", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getAttributesForOntology"),
      "",
      "getAttributesForOntology",
      [ ["in", "String_1", ["::SOAP::SOAPString"]],
        ["retval", "result", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getChildNodes"),
      "",
      "getChildNodes",
      [ ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "String_2", ["::SOAP::SOAPString"]],
        ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["retval", "result", ["AssociationBeanResultList", "http://org.ncbo.stanford.server/beans", "AssociationBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getHierarchyToRootImageUrl"),
      "",
      "getHierarchyToRootImageUrl",
      [ ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "String_2", ["::SOAP::SOAPString"]],
        ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["retval", "result", ["::SOAP::SOAPString"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNCBOOntologies"),
      "",
      "getNCBOOntologies",
      [ ["retval", "result", ["NCBOOntologyList", "http://org.ncbo.stanford.server/beans", "NCBOOntologyList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNCBOOntologiesByCategory"),
      "",
      "getNCBOOntologiesByCategory",
      [ ["in", "String_1", ["::SOAP::SOAPString"]],
        ["retval", "result", ["NCBOOntologyList", "http://org.ncbo.stanford.server/beans", "NCBOOntologyList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNCBOOntology"),
      "",
      "getNCBOOntology",
      [ ["in", "String_1", ["::SOAP::SOAPString"]],
        ["retval", "result", ["NCBOOntology", "http://org.ncbo.stanford.server/beans", "NCBOOntology"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNetworkNeighborhoodImageUrl"),
      "",
      "getNetworkNeighborhoodImageUrl",
      [ ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "String_2", ["::SOAP::SOAPString"]],
        ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["retval", "result", ["::SOAP::SOAPString"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNode"),
      "",
      "getNode",
      [ ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "String_2", ["::SOAP::SOAPString"]],
        ["retval", "result", ["NodeBeanResult", "http://org.ncbo.stanford.server/beans", "NodeBeanResult"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNodeIdContains"),
      "",
      "getNodeIdContains",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNodeIdEndsWith"),
      "",
      "getNodeIdEndsWith",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNodeIdExactMatch"),
      "",
      "getNodeIdExactMatch",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNodeIdStartsWith"),
      "",
      "getNodeIdStartsWith",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNodeNameContains"),
      "",
      "getNodeNameContains",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNodeNameEndsWith"),
      "",
      "getNodeNameEndsWith",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNodeNameExactMatch"),
      "",
      "getNodeNameExactMatch",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNodeNameSoundsLike"),
      "",
      "getNodeNameSoundsLike",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getNodeNameStartsWith"),
      "",
      "getNodeNameStartsWith",
      [ ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "boolean_1", ["::SOAP::SOAPBoolean"]],
        ["retval", "result", ["SearchBeanResultList", "http://org.ncbo.stanford.server/beans", "SearchBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getParentNodes"),
      "",
      "getParentNodes",
      [ ["in", "String_1", ["::SOAP::SOAPString"]],
        ["in", "String_2", ["::SOAP::SOAPString"]],
        ["in", "StringList_1", ["StringList", "http://org.ncbo.stanford.server/beans", "StringList"]],
        ["retval", "result", ["AssociationBeanResultList", "http://org.ncbo.stanford.server/beans", "AssociationBeanResultList"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ],
    [ XSD::QName.new(NsBeans, "getTopLevelNodes"),
      "",
      "getTopLevelNodes",
      [ ["in", "String_1", ["::SOAP::SOAPString"]],
        ["retval", "result", ["AssociationBeanResult", "http://org.ncbo.stanford.server/beans", "AssociationBeanResult"]] ],
      { :request_style =>  :rpc, :request_use =>  :literal,
        :response_style => :rpc, :response_use => :literal,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = NCBOServiceMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = NCBOServiceMappingRegistry::LiteralRegistry
    init_methods
  end

private

  def init_methods
    Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        add_document_operation(*definitions)
      else
        add_rpc_operation(*definitions)
        qname = definitions[0]
        name = definitions[2]
        if qname.name != name and qname.name.capitalize == name.capitalize
          ::SOAP::Mapping.define_singleton_method(self, qname.name) do |*arg|
            __send__(name, *arg)
          end
        end
      end
    end
  end
end

