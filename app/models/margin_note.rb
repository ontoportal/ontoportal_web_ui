class MarginNote < ActiveRecord::Base
  acts_as_tree :order =>:id

  
  NOTE_TYPES = {
  1 => "Advice",
  2 => "Comment",
  3 => "Example",
  4 => "Explanation",
  5 => "Proposal",
  6 => "Question",
  7 => "SeeAlso"
  }
  
  def type_label  
    return NOTE_TYPES[self.note_type]
  end
  
  def user
    return DataAccess.getUser(self.user_id)
  end
  
  def after_create
    CACHE.delete("#{self.ontology_id}::#{self.concept_id}_NoteCount")
  end
  
  def ontology
    DataAccess.getOntology(self.ontology_version_id)
  end
  
  def concept
    DataAccess.getNode(self.ontology_version_id,self.concept_id)
  end
  
  
end
