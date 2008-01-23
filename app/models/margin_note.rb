class MarginNote < ActiveRecord::Base
  acts_as_tree :order =>:id
  belongs_to :user
  
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
  
end
