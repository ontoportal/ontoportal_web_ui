require 'rubygems'
require 'xml/libxml'
require 'open-uri'

class NodeWrapper
  
  attr_accessor :id
  attr_accessor :name  
  attr_accessor :isActive
  attr_accessor :properties
  attr_accessor :version_id
  attr_accessor :child_size
  attr_accessor :children
  attr_accessor :parent_association


  
end

class SaxParser
  def initialize(xml)
    @parser = XML::SaxParser.new
    @parser.string = xml
    @parser.callbacks = Handler.new
  end

  def parse
    @parser.parse
    @parser.callbacks.elements
  end
end

class Handler
  attr_accessor :elements
  attr_accessor :currentNode
  attr_accessor :relationships
  attr_accessor :currentParent
  def initialize
    @elements = []
  end

  def on_start_element(element, attributes)
    if element=='classbean'
      
      @startNode=true
      self.currentNode = NodeWrapper.new
      puts "classbean"
    end
    
    if element=='id'
      @grab_id=true
    end
    
    if element=='label'
      @grab_label=true
    end
    
  end

  def on_characters(characters = '')
    if @grab_id
      puts characters
      self.currentNode.id=characters
    end
    if @grab_label
      self.currentNode.name=characters
    end    
    
  end

  def on_end_element(element)
     if element=='classbean'
        @startNode=false
        @elements << self.currentNode
      end

      if element=='id'
        @grab_id=false
      end

      if element=='label'
        @grab_label=false
      end
  end

  # Handle all missing methods of the SAX events chain.
  # You can implement or omit one or many of those methods, without any raising Exception.
  # 
  # The complete chain is:
  #   on_start_document
  #   on_processing_instruction(instruction, arguments)
  #   on_start_element(element, attributes)
  #   on_characters(characters = '')
  #   on_end_element(element)
  #   on_end_document
  def method_missing(method_name, *attributes, &block)
  end
end

xml = open("http://ncbo-core-prod1.stanford.edu:8080/bioportal/rest/concepts/38400/root").read
puts SaxParser.new(xml).parse.inspect