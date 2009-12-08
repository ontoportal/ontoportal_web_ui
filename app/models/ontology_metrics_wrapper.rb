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
  
  # These metrics contains list, must be Array or Hash
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
  
  # Are all of the following properties triggered for every class?
  attr_accessor :classesWithOneSubclassAll
  attr_accessor :classesWithMoreThanXSubclassesAll
  attr_accessor :classesWithNoDocumentationAll
  attr_accessor :classesWithNoAuthorAll
  attr_accessor :classesWithMoreThanOnePropertyValueAll
  
  # List of all metrics with lists
  METRICS_WITH_LISTS = ["classesWithOneSubclass", "classesWithMoreThanXSubclasses",
      "classesWithNoDocumentation", "classesWithNoAuthor", "classesWithMoreThanOnePropertyValue"]
  
  # Strings for use in the metrics view
  ONE_SUBCLASS_STRING = "No definition property specified or no values for the definition property"
  MORE_THAN_X_SUBLCASSES_STRING = "No definition property specified or no values for the definition property"
  DOCUMENTATION_MISSING_STRING = "No definition property specified or no values for the definition property"
  AUTHOR_MISSING_STRING = "No author property specified or no values for the author property"
  MORE_THAN_ONE_PROPERTY_STRING = "No definition property specified or no values for the definition property"
  
  # Initialize values
  def initialize
    self.classesWithOneSubclass = Array.new
    self.classesWithMoreThanXSubclasses = Hash.new
    self.classesWithNoDocumentation = Array.new
    self.classesWithNoAuthor = Array.new
    self.classesWithMoreThanOnePropertyValue = Array.new
  end
  
  # Methods that return appropriate string when all classes are triggered for a given metric
  def classesWithOneSubclass_all
    return ONE_SUBCLASS_STRING
  end

  def classesWithMoreThanXSubclasses_all
    return MORE_THAN_X_SUBLCASSES_STRING
  end

  def classesWithNoDocumentation_all
    return DOCUMENTATION_MISSING_STRING
  end

  def classesWithNoAuthor_all
    return AUTHOR_MISSING_STRING
  end

  def classesWithMoreThanOnePropertyValue_all
    return MORE_THAN_ONE_PROPERTY_STRING
  end
  
  def percentage(metric)
    if self.send(:"#{metric}LimitPassed") == false
      return self.send(:"#{metric}").length.to_f / self.numberOfClasses
    else
      return self.send(:"#{metric}LimitPassed").to_f / self.numberOfClasses
    end
  end

end
