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

  def initialize(hash = nil, params = nil)
    self.classesWithOneSubclass = Array.new
    self.classesWithMoreThanXSubclasses = Hash.new
    self.classesWithNoDocumentation = Array.new
    self.classesWithNoAuthor = Array.new
    self.classesWithMoreThanOnePropertyValue = Array.new

    return if hash.nil?
    hash = hash["ontologyMetricsBean"] if hash["ontologyMetricsBean"]

    self.id = hash["id"]
    self.averageNumberOfSiblings = hash["averageNumberOfSiblings"]
    self.maximumDepth = hash["maximumDepth"]
    self.classesWithMoreThanOnePropertyValue = hash["classesWithMoreThanOnePropertyValue"]
    self.classesWithNoAuthor = hash["classesWithNoAuthor"]
    self.classesWithNoDocumentation = hash["classesWithNoDocumentation"]
    self.numberOfIndividuals = hash["numberOfIndividuals"]
    self.classesWithMoreThanXSubclasses = hash["classesWithMoreThanXSubclasses"]
    self.maximumNumberOfSiblings = hash["maximumNumberOfSiblings"]
    self.classesWithOneSubclass = hash["classesWithOneSubclass"]
    self.numberOfProperties = hash["numberOfProperties"]
    self.numberOfClasses = hash["numberOfClasses"]
  end

  def empty?
    self.numberOfClasses.nil? || self.numberOfClasses.to_s.empty?
  end

end
