
require 'NCBOService.rb'
require 'soap/mapping'

module NCBOServiceMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsBeans = "http://org.ncbo.stanford.server/beans"
  NsJaws = "http://beans.server.stanford.ncbo.org/jaws"

  EncodedRegistry.register(
    :class => AssociationBeanResult,
    :schema_type => XSD::QName.new(NsBeans, "AssociationBeanResult"),
    :schema_element => [
      ["associationName", "SOAP::SOAPString"],
      ["nodeBeanResultArr", "NodeBeanResult[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => AssociationBeanResultList,
    :schema_type => XSD::QName.new(NsBeans, "AssociationBeanResultList"),
    :schema_element => [
      ["dummyForJbossBug", "SOAP::SOAPInt"],
      ["result", "AssociationBeanResult_[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => NCBOOntology,
    :schema_type => XSD::QName.new(NsBeans, "NCBOOntology"),
    :schema_element => [
      ["coreFormat", "SOAP::SOAPString"],
      ["currentVersion", "SOAP::SOAPString"],
      ["displayLabel", "SOAP::SOAPString"],
      ["downloadPath", "SOAP::SOAPString"],
      ["metadataPath", "SOAP::SOAPString"],
      ["releaseDate", "SOAP::SOAPLong"]
    ]
  )

  EncodedRegistry.register(
    :class => NCBOOntologyList,
    :schema_type => XSD::QName.new(NsBeans, "NCBOOntologyList"),
    :schema_element => [
      ["dummyForJbossBug", "SOAP::SOAPInt"],
      ["result", "NCBOOntology[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => NodeBeanResult,
    :schema_type => XSD::QName.new(NsBeans, "NodeBeanResult"),
    :schema_element => [
      ["id", "SOAP::SOAPString"],
      ["isActive", "SOAP::SOAPBoolean"],
      ["name", "SOAP::SOAPString"],
      ["children","SOAP::SOAPInt"],
      ["propertyValuePair", "PropertyValue[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => SearchBeanResultList,
    :schema_type => XSD::QName.new(NsBeans, "SearchBeanResultList"),
    :schema_element => [
      ["dummyForJbossBug", "SOAP::SOAPInt"],
      ["result", "SearchBeanResult[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => StringList,
    :schema_type => XSD::QName.new(NsBeans, "StringList"),
    :schema_element => [
      ["dummyForJbossBug", "SOAP::SOAPInt"],
      ["stringArr", "SOAP::SOAPString[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => AssociationBeanResult_,
    :schema_type => XSD::QName.new(NsJaws, "AssociationBeanResult"),
    :schema_element => [
      ["associationName", "SOAP::SOAPString"],
      ["nodeBeanResultArr", "NodeBeanResult_[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => NodeBeanResult_,
    :schema_type => XSD::QName.new(NsJaws, "NodeBeanResult"),
    :schema_element => [
      ["id", "SOAP::SOAPString"],
      ["isActive", "SOAP::SOAPBoolean"],
      ["name", "SOAP::SOAPString"],
      ["children", "SOAP::SOAPInt"],
      ["propertyValuePair", "PropertyValue[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => PropertyValue,
    :schema_type => XSD::QName.new(NsJaws, "PropertyValue"),
    :schema_element => [
      ["key", "SOAP::SOAPString"],
      ["value", "SOAP::SOAPString"]
    ]
  )

  EncodedRegistry.register(
    :class => SearchBeanResult,
    :schema_type => XSD::QName.new(NsJaws, "SearchBeanResult"),
    :schema_element => [
      ["countRemaining", "SOAP::SOAPInt"],
      ["nodeBeanArr", "NodeBeanResult[]", [0, nil]],
      ["ontologyDisplayLabel", "SOAP::SOAPString"]
    ]
  )

  LiteralRegistry.register(
    :class => AssociationBeanResult,
    :schema_type => XSD::QName.new(NsBeans, "AssociationBeanResult"),
    :schema_element => [
      ["associationName", "SOAP::SOAPString"],
      ["nodeBeanResultArr", "NodeBeanResult[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => AssociationBeanResultList,
    :schema_type => XSD::QName.new(NsBeans, "AssociationBeanResultList"),
    :schema_element => [
      ["dummyForJbossBug", "SOAP::SOAPInt"],
      ["result", "AssociationBeanResult_[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => NCBOOntology,
    :schema_type => XSD::QName.new(NsBeans, "NCBOOntology"),
    :schema_element => [
      ["coreFormat", "SOAP::SOAPString"],
      ["currentVersion", "SOAP::SOAPString"],
      ["displayLabel", "SOAP::SOAPString"],
      ["downloadPath", "SOAP::SOAPString"],
      ["metadataPath", "SOAP::SOAPString"],
      ["releaseDate", "SOAP::SOAPLong"]
    ]
  )

  LiteralRegistry.register(
    :class => NCBOOntologyList,
    :schema_type => XSD::QName.new(NsBeans, "NCBOOntologyList"),
    :schema_element => [
      ["dummyForJbossBug", "SOAP::SOAPInt"],
      ["result", "NCBOOntology[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => NodeBeanResult,
    :schema_type => XSD::QName.new(NsBeans, "NodeBeanResult"),
    :schema_element => [
      ["id", "SOAP::SOAPString"],
      ["isActive", "SOAP::SOAPBoolean"],
      ["name", "SOAP::SOAPString"],
      ["children","SOAP::SOAPInt"],
      ["propertyValuePair", "PropertyValue[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => SearchBeanResultList,
    :schema_type => XSD::QName.new(NsBeans, "SearchBeanResultList"),
    :schema_element => [
      ["dummyForJbossBug", "SOAP::SOAPInt"],
      ["result", "SearchBeanResult[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => StringList,
    :schema_type => XSD::QName.new(NsBeans, "StringList"),
    :schema_element => [
      ["dummyForJbossBug", "SOAP::SOAPInt"],
      ["stringArr", "SOAP::SOAPString[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => AssociationBeanResult_,
    :schema_type => XSD::QName.new(NsJaws, "AssociationBeanResult"),
    :schema_element => [
      ["associationName", "SOAP::SOAPString"],
      ["nodeBeanResultArr", "NodeBeanResult_[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => NodeBeanResult_,
    :schema_type => XSD::QName.new(NsJaws, "NodeBeanResult"),
    :schema_element => [
      ["id", "SOAP::SOAPString"],
      ["isActive", "SOAP::SOAPBoolean"],
      ["name", "SOAP::SOAPString"],
      ["children", "SOAP::SOAPInt"],
      ["propertyValuePair", "PropertyValue[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => PropertyValue,
    :schema_type => XSD::QName.new(NsJaws, "PropertyValue"),
    :schema_element => [
      ["key", "SOAP::SOAPString"],
      ["value", "SOAP::SOAPString"]
    ]
  )

  LiteralRegistry.register(
    :class => SearchBeanResult,
    :schema_type => XSD::QName.new(NsJaws, "SearchBeanResult"),
    :schema_element => [
      ["countRemaining", "SOAP::SOAPInt"],
      ["nodeBeanArr", "NodeBeanResult[]", [0, nil]],
      ["ontologyDisplayLabel", "SOAP::SOAPString"]
    ]
  )
end
