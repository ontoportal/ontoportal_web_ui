
require 'NCBOServiceDriver.rb'

endpoint_url = ARGV.shift
obj = NCBOWebserviceEndpoint.new("http://171.65.32.37/ncboservicebeans/NCBOWebserviceBean?wsdl")

# run ruby with -d to see SOAP wiredumps.
obj.wiredump_dev = STDOUT

# SYNOPSIS
#   getAssociationsForOntology(string_1)
#
# ARGS
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   result          StringList - {http://org.ncbo.stanford.server/beans}StringList
#
#string_1 = nil
#puts obj.getAssociationsForOntology(string_1)

# SYNOPSIS
#   getAttributeValueContains(stringList_1, string_1, stringList_2, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   stringList_2    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = stringList_2 = boolean_1 = nil
#puts obj.getAttributeValueContains(stringList_1, string_1, stringList_2, boolean_1)

# SYNOPSIS
#   getAttributeValueEndsWith(stringList_1, string_1, stringList_2, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   stringList_2    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = stringList_2 = boolean_1 = nil
#puts obj.getAttributeValueEndsWith(stringList_1, string_1, stringList_2, boolean_1)

# SYNOPSIS
#   getAttributeValueSoundsLike(stringList_1, string_1, stringList_2, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   stringList_2    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = stringList_2 = boolean_1 = nil
#puts obj.getAttributeValueSoundsLike(stringList_1, string_1, stringList_2, boolean_1)

# SYNOPSIS
#   getAttributeValueStartsWith(stringList_1, string_1, stringList_2, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   stringList_2    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = stringList_2 = boolean_1 = nil
#puts obj.getAttributeValueStartsWith(stringList_1, string_1, stringList_2, boolean_1)

# SYNOPSIS
#   getAttributesForOntology(string_1)
#
# ARGS
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   result          StringList - {http://org.ncbo.stanford.server/beans}StringList
#
#string_1 = nil
#puts obj.getAttributesForOntology(string_1)

# SYNOPSIS
#   getChildNodes(string_1, string_2, stringList_1)
#
# ARGS
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   string_2        C_String - {http://www.w3.org/2001/XMLSchema}string
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#
# RETURNS
#   result          AssociationBeanResultList - {http://org.ncbo.stanford.server/beans}AssociationBeanResultList
#
#string_1 = string_2 = stringList_1 = nil
#puts obj.getChildNodes(string_1, string_2, stringList_1)

# SYNOPSIS
#   getHierarchyToRootImageUrl(string_1, string_2, stringList_1)
#
# ARGS
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   string_2        C_String - {http://www.w3.org/2001/XMLSchema}string
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#
# RETURNS
#   result          C_String - {http://www.w3.org/2001/XMLSchema}string
#
#string_1 = string_2 = stringList_1 = nil
#puts obj.getHierarchyToRootImageUrl(string_1, string_2, stringList_1)

# SYNOPSIS
#   getNCBOOntologies
#
# ARGS
#   N/A
#
# RETURNS
#   result          NCBOOntologyList - {http://org.ncbo.stanford.server/beans}NCBOOntologyList
#

puts obj.getNCBOOntologies

# SYNOPSIS
#   getNCBOOntologiesByCategory(string_1)
#
# ARGS
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   result          NCBOOntologyList - {http://org.ncbo.stanford.server/beans}NCBOOntologyList
#
#string_1 = nil
#puts obj.getNCBOOntologiesByCategory(string_1)

# SYNOPSIS
#   getNCBOOntology(string_1)
#
# ARGS
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   result          NCBOOntology - {http://org.ncbo.stanford.server/beans}NCBOOntology
#
#string_1 = nil
#puts obj.getNCBOOntology(string_1)

# SYNOPSIS
#   getNetworkNeighborhoodImageUrl(string_1, string_2, stringList_1)
#
# ARGS
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   string_2        C_String - {http://www.w3.org/2001/XMLSchema}string
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#
# RETURNS
#   result          C_String - {http://www.w3.org/2001/XMLSchema}string
#
string_1 ="Xenopus anatomy and development"
string_2 ="XAO:0000176"
stringList_1 = StringList.new(1,["is_a"])
puts obj.getNetworkNeighborhoodImageUrl(string_1, string_2, stringList_1)

# SYNOPSIS
#   getNode(string_1, string_2)
#
# ARGS
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   string_2        C_String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   result          NodeBeanResult - {http://org.ncbo.stanford.server/beans}NodeBeanResult
#
#string_1 = string_2 = nil
#puts obj.getNode(string_1, string_2)

# SYNOPSIS
#   getNodeIdContains(stringList_1, string_1, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = boolean_1 = nil
#puts obj.getNodeIdContains(stringList_1, string_1, boolean_1)

# SYNOPSIS
#   getNodeIdEndsWith(stringList_1, string_1, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = boolean_1 = nil
#puts obj.getNodeIdEndsWith(stringList_1, string_1, boolean_1)

# SYNOPSIS
#   getNodeIdExactMatch(stringList_1, string_1, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = boolean_1 = nil
#puts obj.getNodeIdExactMatch(stringList_1, string_1, boolean_1)

# SYNOPSIS
#   getNodeIdStartsWith(stringList_1, string_1, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = boolean_1 = nil
#puts obj.getNodeIdStartsWith(stringList_1, string_1, boolean_1)

# SYNOPSIS
#   getNodeNameContains(stringList_1, string_1, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = boolean_1 = nil
#puts obj.getNodeNameContains(stringList_1, string_1, boolean_1)

# SYNOPSIS
#   getNodeNameEndsWith(stringList_1, string_1, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = boolean_1 = nil
#puts obj.getNodeNameEndsWith(stringList_1, string_1, boolean_1)

# SYNOPSIS
#   getNodeNameExactMatch(stringList_1, string_1, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = boolean_1 = nil
#puts obj.getNodeNameExactMatch(stringList_1, string_1, boolean_1)

# SYNOPSIS
#   getNodeNameSoundsLike(stringList_1, string_1, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = boolean_1 = nil
#puts obj.getNodeNameSoundsLike(stringList_1, string_1, boolean_1)

# SYNOPSIS
#   getNodeNameStartsWith(stringList_1, string_1, boolean_1)
#
# ARGS
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   boolean_1       Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   result          SearchBeanResultList - {http://org.ncbo.stanford.server/beans}SearchBeanResultList
#
#stringList_1 = string_1 = boolean_1 = nil
#puts obj.getNodeNameStartsWith(stringList_1, string_1, boolean_1)

# SYNOPSIS
#   getParentNodes(string_1, string_2, stringList_1)
#
# ARGS
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#   string_2        C_String - {http://www.w3.org/2001/XMLSchema}string
#   stringList_1    StringList - {http://org.ncbo.stanford.server/beans}StringList
#
# RETURNS
#   result          AssociationBeanResultList - {http://org.ncbo.stanford.server/beans}AssociationBeanResultList
#
#string_1 = string_2 = stringList_1 = nil
#puts obj.getParentNodes(string_1, string_2, stringList_1)

# SYNOPSIS
#   getTopLevelNodes(string_1)
#
# ARGS
#   string_1        C_String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   result          AssociationBeanResult - {http://org.ncbo.stanford.server/beans}AssociationBeanResult
#
#string_1 = nil
#puts obj.getTopLevelNodes(string_1)


