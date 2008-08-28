
require 'xsd/qname'

# {http://org.ncbo.stanford.server/beans}AssociationBeanResult
#   associationName - SOAP::SOAPString
#   nodeBeanResultArr - NodeBeanResult
class AssociationBeanResult
  attr_accessor :associationName
  attr_accessor :nodeBeanResultArr

  def initialize(associationName = nil, nodeBeanResultArr = [])
    @associationName = associationName
    @nodeBeanResultArr = nodeBeanResultArr
  end
end

# {http://org.ncbo.stanford.server/beans}AssociationBeanResultList
#   dummyForJbossBug - SOAP::SOAPInt
#   result - AssociationBeanResult_
class AssociationBeanResultList
  attr_accessor :dummyForJbossBug
  attr_accessor :result

  def initialize(dummyForJbossBug = nil, result = [])
    @dummyForJbossBug = dummyForJbossBug
    @result = result
  end
end

# {http://org.ncbo.stanford.server/beans}NCBOOntology
#   coreFormat - SOAP::SOAPString
#   currentVersion - SOAP::SOAPString
#   displayLabel - SOAP::SOAPString
#   downloadPath - SOAP::SOAPString
#   metadataPath - SOAP::SOAPString
#   releaseDate - SOAP::SOAPLong
class NCBOOntology
  attr_accessor :coreFormat
  attr_accessor :currentVersion
  attr_accessor :displayLabel
  attr_accessor :downloadPath
  attr_accessor :metadataPath
  attr_accessor :releaseDate

  def initialize(coreFormat = nil, currentVersion = nil, displayLabel = nil, downloadPath = nil, metadataPath = nil, releaseDate = nil)
    @coreFormat = coreFormat
    @currentVersion = currentVersion
    @displayLabel = displayLabel
    @downloadPath = downloadPath
    @metadataPath = metadataPath
    @releaseDate = releaseDate
  end
end

# {http://org.ncbo.stanford.server/beans}NCBOOntologyList
#   dummyForJbossBug - SOAP::SOAPInt
#   result - NCBOOntology
class NCBOOntologyList
  attr_accessor :dummyForJbossBug
  attr_accessor :result

  def initialize(dummyForJbossBug = nil, result = [])
    @dummyForJbossBug = dummyForJbossBug
    @result = result
  end
end

# {http://org.ncbo.stanford.server/beans}NodeBeanResult
#   id - SOAP::SOAPString
#   isActive - SOAP::SOAPBoolean
#   name - SOAP::SOAPString
#   children - SOAP::SOAPInt
#   propertyValuePair - PropertyValue
class NodeBeanResult
  attr_accessor :id
  attr_accessor :isActive
  attr_accessor :name
  attr_accessor :children
  attr_accessor :propertyValuePair


  def initialize(id = nil, isActive = nil, name = nil,children = nil, propertyValuePair = [])
    @id = id
    @isActive = isActive
    @name = name
    @children = children
    @propertyValuePair = propertyValuePair
  end
end

# {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#   dummyForJbossBug - SOAP::SOAPInt
#   result - SearchBeanResult
class SearchBeanResultList
  attr_accessor :dummyForJbossBug
  attr_accessor :result

  def initialize(dummyForJbossBug = nil, result = [])
    @dummyForJbossBug = dummyForJbossBug
    @result = result
  end
end

# {http://org.ncbo.stanford.server/beans}StringList
#   dummyForJbossBug - SOAP::SOAPInt
#   stringArr - SOAP::SOAPString
class StringList
  attr_accessor :dummyForJbossBug
  attr_accessor :stringArr

  def initialize(dummyForJbossBug = nil, stringArr = [])
    @dummyForJbossBug = dummyForJbossBug
    @stringArr = stringArr
  end
end

# {http://beans.server.stanford.ncbo.org/jaws}AssociationBeanResult
#   associationName - SOAP::SOAPString
#   nodeBeanResultArr - NodeBeanResult_
class AssociationBeanResult_
  attr_accessor :associationName
  attr_accessor :nodeBeanResultArr

  def initialize(associationName = nil, nodeBeanResultArr = [])
    @associationName = associationName
    @nodeBeanResultArr = nodeBeanResultArr
  end
end

# {http://beans.server.stanford.ncbo.org/jaws}NodeBeanResult
#   id - SOAP::SOAPString
#   isActive - SOAP::SOAPBoolean
#   name - SOAP::SOAPString
#   children - SOAP::SOAPInt
#   propertyValuePair - PropertyValue
class NodeBeanResult_
  attr_accessor :id
  attr_accessor :isActive
  attr_accessor :name
  attr_accessor :children
  attr_accessor :propertyValuePair


  def initialize(id = nil, isActive = nil, name = nil, children=0 , propertyValuePair = [])
    @id = id
    @isActive = isActive
    @name = name
    @children = children
    @propertyValuePair = propertyValuePair
  end
end

# {http://beans.server.stanford.ncbo.org/jaws}PropertyValue
#   key - SOAP::SOAPString
#   value - SOAP::SOAPString
class PropertyValue
  attr_accessor :key
  attr_accessor :value

  def initialize(key = nil, value = nil)
    @key = key
    @value = value
  end
end

# {http://beans.server.stanford.ncbo.org/jaws}SearchBeanResult
#   countRemaining - SOAP::SOAPInt
#   nodeBeanArr - NodeBeanResult
#   ontologyDisplayLabel - SOAP::SOAPString
class SearchBeanResult
  attr_accessor :countRemaining
  attr_accessor :nodeBeanArr
  attr_accessor :ontologyDisplayLabel

  def initialize(countRemaining = nil, nodeBeanArr = [], ontologyDisplayLabel = nil)
    @countRemaining = countRemaining
    @nodeBeanArr = nodeBeanArr
    @ontologyDisplayLabel = ontologyDisplayLabel
  end
end
