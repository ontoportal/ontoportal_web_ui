class OntologyMetricsWrapper
  attr_accessor :id
  attr_accessor :ontologyId
  attr_accessor :numberOfAxioms
  attr_accessor :numberOfClasses
  attr_accessor :numberOfIndividuals
  attr_accessor :numberOfProperties
  attr_accessor :maximumDepth
  attr_accessor :maximumNumberOfSiblings
  attr_accessor :averageNumberOfSiblings
  attr_accessor :classesWithOneSubclass
  attr_accessor :classesWithMoreThanXSubclasses
  attr_accessor :classesWithNoDocumentation
  attr_accessor :classesWithNoAuthor
  attr_accessor :classesWithMoreThanOnePropertyValue
  
  # Used to calculate percentage of classes in certain metrics
  CLASS_LIST_LIMIT = 200
  # Booleans for whether or not the limit above is passed
  attr_accessor :classesWithMoreThanXSubclassesLimitPassed
  attr_accessor :classesWithOneSubclassLimitPassed
  attr_accessor :classesWithNoDocumentationLimitPassed
  attr_accessor :classesWithNoAuthorLimitPassed
  attr_accessor :classesWithMoreThanOnePropertyValueLimitPassed
  # Percentage of classes matching metric
  attr_accessor :classesWithOneSubclassPercentage
  attr_accessor :classesWithMoreThanXSubclassesPercentage
  attr_accessor :classesWithNoDocumentationPercentage
  attr_accessor :classesWithNoAuthorPercentage
  attr_accessor :classesWithMoreThanOnePropertyValuePercentage
  # Are all of the following properties missing?
  attr_accessor :classesWithNoDocumentationMissing
  attr_accessor :classesWithNoAuthorMissing

  
end
