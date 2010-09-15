class Note
  attr_accessor :id
  attr_accessor :ontologyId
  attr_accessor :type
  attr_accessor :author
  attr_accessor :created
  attr_accessor :updated
  attr_accessor :subject
  attr_accessor :body
  attr_accessor :status
  attr_accessor :archived
  attr_accessor :createdInOntologyVersion
  attr_accessor :archivedInOntologyVersion
  attr_accessor :appliesTo
  attr_accessor :associated
  attr_accessor :values


  def initialize(hash = nil, params = nil)
    if hash.nil? || !hash['id']
      return nil
    end

    self.associated = []

    hash.each do |key,value|
      if key.eql?("associated")
        associated = []
        value.each { |note| associated << Note.new(note, params) }
        self.associated = associated
        next
      end
      
      if key.eql?("appliesToList")
        self.appliesTo = value['appliesTo']
        next
      end

      begin
        self.send("#{key}=", value)
      rescue Exception
        LOG.add :debug, "Missing '#{key}' attribute in NodeWrapper"
      end
    end
  end
  
  def empty?
    self.id.nil?
  end
  
  def ontology
    DataAccess.getOntology(self.createdInOntologyVersion)
  end
  
end