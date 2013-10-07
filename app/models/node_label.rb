class NodeLabel
  attr_accessor :label
  attr_accessor :obsolete

  def obsolete?
    self.obsolete.eql?("1")
  end

  def label_html
    self.obsolete? ? "<span class='obsolete_class' title='This class is obsolete'>#{self.label}</span>" : self.label
  end
end
